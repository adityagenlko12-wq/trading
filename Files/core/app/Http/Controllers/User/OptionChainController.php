<?php

namespace App\Http\Controllers\User;

use App\Constants\Status;
use App\Http\Controllers\Controller;
use App\Models\Currency;
use App\Models\OptionContract;
use App\Models\OptionPosition;
use App\Models\Wallet;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Exception;

class OptionChainController extends Controller
{
    public function index(Request $request, $symbol = 'NSE_INDEX|Nifty 50')
    {
        $pageTitle = "Option Chain - " . explode('|', $symbol)[1];
        
        $provider = defaultCurrencyDataProvider();
        $chainData = [];
        $expiries = [];

        try {
            $expiry = $request->expiry;
            
            // 1. Fetch available contracts to extract all unique expiry dates
            $contracts = $provider->apiCall(['instrument_key' => $symbol], null, 'v2/option/contract');
            if (isset($contracts->status) && $contracts->status == 'success' && !empty($contracts->data)) {
                foreach ($contracts->data as $item) {
                    $exp = $item->expiry ?? null;
                    if ($exp) {
                        $expiries[$exp] = $exp;
                    }
                }
                ksort($expiries);
            }
            
            // 2. Default to nearest expiry if not provided in request
            if (!$expiry && !empty($expiries)) {
                $expiry = array_key_first($expiries);
                $request->merge(['expiry' => $expiry]);
            }
            
            // 3. Fetch the structured option chain for selected expiry
            if ($expiry) {
                $chain = $provider->getOptionChain($symbol, $expiry);
                if ($chain && is_array($chain)) {
                    $chainData = $chain;
                }
            }
        } catch (Exception $e) {
            // API or connection error
        }

        // Get user's open positions to display current options portfolio
        $positions = OptionPosition::where('user_id', auth()->id())
            ->with('contract')
            ->where('quantity', '!=', 0)
            ->get();

        // Get user's Spot INR wallet balance
        $inrWallet = Wallet::where('user_id', auth()->id())
            ->whereHas('currency', function($q) {
                $q->where('symbol', 'INR');
            })->spot()->first();

        // Fetch all seeded stocks for the dropdown (dynamic, not hardcoded)
        $availableStocks = Currency::where('type', 1)->where('status', 1)->orderBy('name')->get();

        return view('Template::user.options.chain', compact('pageTitle', 'symbol', 'chainData', 'expiries', 'positions', 'inrWallet', 'availableStocks'));
    }

    public function trade(Request $request)
    {
        $request->validate([
            'underlying_symbol' => 'required|string',
            'instrument_key'    => 'required|string',
            'strike_price'      => 'required|numeric',
            'option_type'       => 'required|in:CE,PE',
            'expiry_date'       => 'required|date',
            'lot_size'          => 'required|integer|gt:0',
            'premium'           => 'required|numeric|gt:0',
            'quantity'          => 'required|integer|gt:0', // Number of contracts/lots
            'trade_side'        => 'required|in:buy,sell'
        ]);

        $user = auth()->user();

        // 1. Get or Create the Option Contract record in the DB
        $contract = OptionContract::firstOrCreate(
            ['instrument_key' => $request->instrument_key],
            [
                'underlying_symbol' => $request->underlying_symbol,
                'strike_price'      => $request->strike_price,
                'option_type'       => $request->option_type,
                'expiry_date'       => $request->expiry_date,
                'lot_size'          => $request->lot_size,
                'last_price'        => $request->premium
            ]
        );

        // Update premium price in contract
        $contract->last_price = $request->premium;
        $contract->save();

        // 2. Fetch Spot INR Wallet to check paper balance
        $inrWallet = Wallet::where('user_id', $user->id)
            ->whereHas('currency', function($q) {
                $q->where('symbol', 'INR');
            })->spot()->first();

        if (!$inrWallet) {
            $notify[] = ['error', 'INR wallet not found. Contact Admin to initialize balance.'];
            return back()->withNotify($notify);
        }

        $totalQty = $request->quantity * $contract->lot_size;
        $totalPremium = $totalQty * $request->premium;

        if ($request->trade_side == 'buy') {
            // Check if user has enough paper balance to buy premium
            if ($inrWallet->balance < $totalPremium) {
                $notify[] = ['error', 'Insufficient INR balance to buy option premium!'];
                return back()->withNotify($notify);
            }

            // Deduct premium from wallet
            $inrWallet->balance -= $totalPremium;
            $inrWallet->save();

            // Record transaction
            $trx = new Transaction();
            $trx->user_id = $user->id;
            $trx->wallet_id = $inrWallet->id;
            $trx->amount = $totalPremium;
            $trx->post_balance = $inrWallet->balance;
            $trx->charge = 0;
            $trx->trx_type = '-';
            $trx->details = "Bought option: {$contract->underlying_symbol} {$contract->expiry_date} {$contract->option_type}@{$contract->strike_price} Qty: {$totalQty}";
            $trx->trx = getTrx();
            $trx->remark = 'option_buy';
            $trx->save();

            // 3. Add to User Positions
            $position = OptionPosition::firstOrNew([
                'user_id' => $user->id,
                'contract_id' => $contract->id
            ]);

            $oldQty = $position->quantity ?? 0;
            $oldPrice = $position->average_price ?? 0;

            $newQty = $oldQty + $totalQty;
            $position->quantity = $newQty;
            $position->average_price = $newQty > 0 ? (($oldQty * $oldPrice) + $totalPremium) / $newQty : 0;
            $position->save();

            $notify[] = ['success', "Option position opened successfully! Bought {$totalQty} units."];
        } else {
            // Options Selling/Shorting: User receives premium, but holds a liability (Quantity becomes negative)
            $inrWallet->balance += $totalPremium;
            $inrWallet->save();

            // Record transaction
            $trx = new Transaction();
            $trx->user_id = $user->id;
            $trx->wallet_id = $inrWallet->id;
            $trx->amount = $totalPremium;
            $trx->post_balance = $inrWallet->balance;
            $trx->charge = 0;
            $trx->trx_type = '+';
            $trx->details = "Short sold option: {$contract->underlying_symbol} {$contract->expiry_date} {$contract->option_type}@{$contract->strike_price} Qty: {$totalQty}";
            $trx->trx = getTrx();
            $trx->remark = 'option_short';
            $trx->save();

            // Add position (negative quantity represents short position)
            $position = OptionPosition::firstOrNew([
                'user_id' => $user->id,
                'contract_id' => $contract->id
            ]);

            $oldQty = $position->quantity ?? 0;
            $oldPrice = $position->average_price ?? 0;

            $newQty = $oldQty - $totalQty;
            $position->quantity = $newQty;
            $position->average_price = $newQty != 0 ? (abs($oldQty * $oldPrice) + $totalPremium) / abs($newQty) : 0;
            $position->save();

            $notify[] = ['success', "Option position shorted successfully! Sold {$totalQty} units."];
        }

        return back()->withNotify($notify);
    }

    public function squareOff(Request $request, $id)
    {
        $position = OptionPosition::where('user_id', auth()->id())->with('contract')->findOrFail($id);

        if ($position->quantity == 0) {
            $notify[] = ['error', 'Position already squared off!'];
            return back()->withNotify($notify);
        }

        $user = auth()->user();
        $contract = $position->contract;
        $qty = $position->quantity;

        // Fetch spot INR wallet
        $inrWallet = Wallet::where('user_id', $user->id)
            ->whereHas('currency', function($q) {
                $q->where('symbol', 'INR');
            })->spot()->first();

        // Squaring off executes at the latest premium LTP.
        // We will fetch LTP via Upstox API quote if available, or fallback to the contract's stored last_price.
        $provider = defaultCurrencyDataProvider();
        $ltp = $contract->last_price;

        try {
            $quote = $provider->apiCall(['symbol' => $contract->instrument_key]);
            if (isset($quote->status) && $quote->status == 'success' && isset($quote->data->{$contract->instrument_key})) {
                $ltp = $quote->data->{$contract->instrument_key}->last_price;
                $contract->last_price = $ltp;
                $contract->save();
            }
        } catch (Exception $e) {
            // Keep using stored last_price
        }

        $payout = abs($qty) * $ltp;

        if ($qty > 0) {
            // Long position squared off: Premium is credited back to INR balance
            $inrWallet->balance += $payout;
            $inrWallet->save();

            $trxType = '+';
            $details = "Squared off (Sold) Option Contract: {$contract->underlying_symbol} {$contract->option_type}@{$contract->strike_price} LTP: {$ltp}";
        } else {
            // Short position squared off: Premium liability must be paid back to cover the short position
            $inrWallet->balance -= $payout;
            $inrWallet->save();

            $trxType = '-';
            $details = "Squared off (Cover Buy) Option Contract: {$contract->underlying_symbol} {$contract->option_type}@{$contract->strike_price} LTP: {$ltp}";
        }

        // Close the position
        $position->quantity = 0;
        $position->average_price = 0;
        $position->save();

        // Record transaction
        $trx = new Transaction();
        $trx->user_id = $user->id;
        $trx->wallet_id = $inrWallet->id;
        $trx->amount = $payout;
        $trx->post_balance = $inrWallet->balance;
        $trx->charge = 0;
        $trx->trx_type = $trxType;
        $trx->details = $details;
        $trx->trx = getTrx();
        $trx->remark = 'option_squareoff';
        $trx->save();

        $notify[] = ['success', 'Option position squared off successfully at premium ' . $ltp];
        return back()->withNotify($notify);
    }
}
