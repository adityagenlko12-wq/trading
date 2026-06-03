@extends($activeTemplate . 'layouts.master')
@section('content')
    <div class="row justify-content-center gy-4">
        <div class="col-xxl-9 col-lg-12">
            
            <!-- Filters Card -->
            <div class="card mb-4">
                <div class="card-header bg--dark">
                    <h5 class="card-title text-white mb-0">@lang('Option Chain Parameters')</h5>
                </div>
                <div class="card-body bg--dark-light">
                    <form action="" method="GET" class="row gy-3 align-items-end">
                        <div class="col-md-4">
                            <label class="form-label text-white">@lang('Underlying Index/Stock')</label>
                            <select name="symbol" class="form-control" onchange="this.form.action = '{{ route('user.options.chain') }}/' + this.value; this.form.submit();">
                                <optgroup label="Index Options">
                                    <option value="NSE_INDEX|Nifty 50" @selected($symbol == 'NSE_INDEX|Nifty 50')>NIFTY 50 (Index)</option>
                                    <option value="NSE_INDEX|Nifty Bank" @selected($symbol == 'NSE_INDEX|Nifty Bank')>BANKNIFTY (Index)</option>
                                    <option value="NSE_INDEX|Nifty Fin Service" @selected($symbol == 'NSE_INDEX|Nifty Fin Service')>FINNIFTY (Index)</option>
                                </optgroup>
                                @if(isset($availableStocks) && $availableStocks->count())
                                    <optgroup label="Stock Options">
                                        @foreach($availableStocks as $stock)
                                            <option value="{{ $stock->symbol }}" @selected($symbol == $stock->symbol)>{{ $stock->name }} (Stock)</option>
                                        @endforeach
                                    </optgroup>
                                @endif
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label text-white">@lang('Select Expiry Date')</label>
                            <select name="expiry" class="form-control" onchange="this.form.submit()">
                                <option value="">@lang('Select Expiry')</option>
                                @foreach($expiries as $exp)
                                    <option value="{{ $exp }}" @selected(request()->expiry == $exp)>{{ showDateTime($exp, 'd M Y') }}</option>
                                @endforeach
                            </select>
                        </div>
                        <div class="col-md-4 text-end">
                            <span class="d-block text-white mb-2">@lang('Available Paper Balance:')</span>
                            <h4 class="text--success mb-0">{{ showAmount($inrWallet->balance ?? 0) }}</h4>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Option Chain Table -->
            <div class="card">
                <div class="card-header bg--dark d-flex justify-content-between align-items-center">
                    <h5 class="card-title text-white mb-0">@lang('Option Chain CE / PE')</h5>
                    <small class="text-white">@lang('Data Feed via Upstox API')</small>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-bordered text-center text-white mb-0" style="background-color: #111a2e; border-color: #212c45;">
                            <thead>
                                <tr style="background-color: #1a243d; color: #8e9bb3;">
                                    <th colspan="3" class="border-bottom-0">@lang('CALLS (CE)')</th>
                                    <th class="border-bottom-0">@lang('STRIKE')</th>
                                    <th colspan="3" class="border-bottom-0">@lang('PUTS (PE)')</th>
                                </tr>
                                <tr style="background-color: #1e2946; color: #a2b0cb; font-size: 13px;">
                                    <th>@lang('Bid/LTP')</th>
                                    <th>@lang('Change')</th>
                                    <th>@lang('Action')</th>
                                    <th>@lang('Strike Price')</th>
                                    <th>@lang('Action')</th>
                                    <th>@lang('Change')</th>
                                    <th>@lang('Bid/LTP')</th>
                                </tr>
                            </thead>
                            <tbody>
                                @forelse($chainData as $strike => $item)
                                    @php
                                        $ce = $item->call_options ?? null;
                                        $pe = $item->put_options ?? null;
                                        $itemExpiry = $item->expiry ?? '';
                                        $itemLotSize = 50;
                                        if ($ce && isset($ce->lot_size)) $itemLotSize = $ce->lot_size;
                                        elseif ($pe && isset($pe->lot_size)) $itemLotSize = $pe->lot_size;
                                    @endphp
                                    <tr style="border-bottom: 1px solid #212c45;">
                                        <!-- CE Details -->
                                        @if($ce)
                                            <td class="text--success">{{ showAmount($ce->market_data->ltp ?? 0, currencyFormat:false) }}</td>
                                            <td class="{{ ($ce->market_data->net_change ?? 0) >= 0 ? 'text--success' : 'text--danger' }}">
                                                {{ ($ce->market_data->net_change ?? 0) >= 0 ? '+' : '' }}{{ showAmount($ce->market_data->net_change ?? 0, currencyFormat:false) }}
                                            </td>
                                            <td>
                                                <button class="btn btn-sm btn--success trade-btn" 
                                                    data-symbol="{{ $symbol }}"
                                                    data-key="{{ $ce->instrument_key }}"
                                                    data-strike="{{ $item->strike_price }}"
                                                    data-type="CE"
                                                    data-expiry="{{ $ce->expiry ?? $itemExpiry }}"
                                                    data-lot="{{ $ce->lot_size ?? $itemLotSize }}"
                                                    data-premium="{{ $ce->market_data->ltp ?? 0 }}">
                                                    @lang('Trade')
                                                </button>
                                            </td>
                                        @else
                                            <td colspan="3" class="text-muted">-</td>
                                        @endif

                                        <!-- Strike Price -->
                                        <td class="bg--dark text-white fw-bold">{{ showAmount($item->strike_price, currencyFormat:false) }}</td>

                                        <!-- PE Details -->
                                        @if($pe)
                                            <td>
                                                <button class="btn btn-sm btn--danger trade-btn" 
                                                    data-symbol="{{ $symbol }}"
                                                    data-key="{{ $pe->instrument_key }}"
                                                    data-strike="{{ $item->strike_price }}"
                                                    data-type="PE"
                                                    data-expiry="{{ $pe->expiry ?? $itemExpiry }}"
                                                    data-lot="{{ $pe->lot_size ?? $itemLotSize }}"
                                                    data-premium="{{ $pe->market_data->ltp ?? 0 }}">
                                                    @lang('Trade')
                                                </button>
                                            </td>
                                            <td class="{{ ($pe->market_data->net_change ?? 0) >= 0 ? 'text--success' : 'text--danger' }}">
                                                {{ ($pe->market_data->net_change ?? 0) >= 0 ? '+' : '' }}{{ showAmount($pe->market_data->net_change ?? 0, currencyFormat:false) }}
                                            </td>
                                            <td class="text--danger">{{ showAmount($pe->market_data->ltp ?? 0, currencyFormat:false) }}</td>
                                        @else
                                            <td colspan="3" class="text-muted">-</td>
                                        @endif
                                    </tr>
                                @empty
                                    <tr>
                                        <td colspan="7" class="text-center text-muted p-5">@lang('No contracts found. Select another underlying asset or expiry date.')</td>
                                    </tr>
                                @endforelse
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Open Options Positions -->
            <div class="card mt-4">
                <div class="card-header bg--dark d-flex justify-content-between align-items-center">
                    <h5 class="card-title text-white mb-0">@lang('Your Open Options Positions (Paper Portfolio)')</h5>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-bordered text-center text-white mb-0" style="background-color: #111a2e; border-color: #212c45;">
                            <thead>
                                <tr style="background-color: #1a243d; color: #8e9bb3; font-size: 13px;">
                                    <th>@lang('Asset')</th>
                                    <th>@lang('Type')</th>
                                    <th>@lang('Expiry')</th>
                                    <th>@lang('Qty')</th>
                                    <th>@lang('Avg Price')</th>
                                    <th>@lang('Current Price')</th>
                                    <th>@lang('Unrealized PNL')</th>
                                    <th>@lang('Action')</th>
                                </tr>
                            </thead>
                            <tbody>
                                @forelse($positions as $pos)
                                    @php
                                        $pnl = ($pos->contract->last_price - $pos->average_price) * $pos->quantity;
                                    @endphp
                                    <tr style="border-bottom: 1px solid #212c45;">
                                        <td>{{ explode('|', $pos->contract->underlying_symbol)[1] ?? $pos->contract->underlying_symbol }} @ {{ $pos->contract->strike_price }}</td>
                                        <td>
                                            <span class="badge {{ $pos->contract->option_type == 'CE' ? 'badge--success' : 'badge--danger' }}">
                                                {{ $pos->contract->option_type }}
                                            </span>
                                        </td>
                                        <td>{{ showDateTime($pos->contract->expiry_date, 'd M Y') }}</td>
                                        <td class="{{ $pos->quantity >= 0 ? 'text--success' : 'text--danger' }}">{{ $pos->quantity }}</td>
                                        <td>{{ showAmount($pos->average_price, currencyFormat:false) }}</td>
                                        <td>{{ showAmount($pos->contract->last_price, currencyFormat:false) }}</td>
                                        <td class="{{ $pnl >= 0 ? 'text--success' : 'text--danger' }}">{{ $pnl >= 0 ? '+' : '' }}{{ showAmount($pnl) }}</td>
                                        <td>
                                            <form action="{{ route('user.options.squareoff', $pos->id) }}" method="POST" onsubmit="return confirm('Square off this position?')">
                                                @csrf
                                                <button type="submit" class="btn btn-sm btn--warning">@lang('Square Off')</button>
                                            </form>
                                        </td>
                                    </tr>
                                @empty
                                    <tr>
                                        <td colspan="8" class="text-center text-muted p-4">@lang('No open options positions in your portfolio.')</td>
                                    </tr>
                                @endforelse
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

        </div>
    </div>

    <!-- Trade Execution Modal -->
    <div id="tradeModal" class="modal fade" tabindex="-1" role="dialog">
        <div class="modal-dialog" role="document">
            <div class="modal-content bg--dark text-white" style="border: 1px solid #212c45;">
                <div class="modal-header border-bottom-0">
                    <h5 class="modal-title text-white"><span class="modal-opt-action"></span> @lang('Option Contract')</h5>
                    <button type="button" class="close text-white bg-transparent border-0" data-bs-dismiss="modal" aria-label="Close">
                        <i class="las la-times fs-4"></i>
                    </button>
                </div>
                <form action="{{ route('user.options.trade') }}" method="POST">
                    @csrf
                    <input type="hidden" name="underlying_symbol">
                    <input type="hidden" name="instrument_key">
                    <input type="hidden" name="strike_price">
                    <input type="hidden" name="option_type">
                    <input type="hidden" name="expiry_date">
                    <input type="hidden" name="lot_size">
                    <input type="hidden" name="premium">

                    <div class="modal-body">
                        <div class="text-center mb-3">
                            <h4 class="text-white mb-1"><span class="modal-opt-underlying"></span> <span class="modal-opt-strike text--success"></span></h4>
                            <span class="badge badge--success modal-opt-type-badge"></span>
                            <span class="text-muted ms-2">Expiry: <span class="modal-opt-expiry text-white"></span></span>
                        </div>

                        <div class="row gy-3">
                            <div class="col-md-6">
                                <label class="form-label text-white">@lang('Premium price (LTP)')</label>
                                <div class="input-group">
                                    <input type="text" class="form-control modal-opt-premium-view" readonly>
                                    <span class="input-group-text bg-secondary border-0 text-white">INR</span>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label text-white">@lang('Lot Size')</label>
                                <input type="text" class="form-control modal-opt-lot-view" readonly>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label text-white">@lang('Action')</label>
                                <select name="trade_side" class="form-control" required>
                                    <option value="buy">BUY / LONG</option>
                                    <option value="sell">SELL / SHORT</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label text-white">@lang('No of Lots')</label>
                                <input type="number" name="quantity" class="form-control" value="1" min="1" required>
                            </div>
                            <div class="col-12 text-end">
                                <span class="d-block text-white-50">Total Est. Premium / Margin Requirement:</span>
                                <h4 class="text--success mb-0" id="total_cost">0.00 INR</h4>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer border-top-0">
                        <button type="submit" class="btn btn--success h-45 w-100">@lang('Place Paper Order')</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
@endsection

@push('script')
    <script>
        (function($) {
            "use strict";

            $('.trade-btn').on('click', function() {
                let btn = $(this);
                let modal = $('#tradeModal');

                modal.find('input[name=underlying_symbol]').val(btn.data('symbol'));
                modal.find('input[name=instrument_key]').val(btn.data('key'));
                modal.find('input[name=strike_price]').val(btn.data('strike'));
                modal.find('input[name=option_type]').val(btn.data('type'));
                modal.find('input[name=expiry_date]').val(btn.data('expiry'));
                modal.find('input[name=lot_size]').val(btn.data('lot'));
                modal.find('input[name=premium]').val(btn.data('premium'));

                modal.find('.modal-opt-underlying').text(btn.data('symbol').split('|')[1]);
                modal.find('.modal-opt-strike').text(btn.data('strike'));
                modal.find('.modal-opt-type-badge').text(btn.data('type'));
                modal.find('.modal-opt-expiry').text(btn.data('expiry'));
                modal.find('.modal-opt-premium-view').val(btn.data('premium'));
                modal.find('.modal-opt-lot-view').val(btn.data('lot'));

                calculateCost();
                modal.modal('show');
            });

            $('input[name=quantity], select[name=trade_side]').on('input change', function() {
                calculateCost();
            });

            function calculateCost() {
                let premium = parseFloat($('input[name=premium]').val()) || 0;
                let lotSize = parseInt($('input[name=lot_size]').val()) || 1;
                let lots = parseInt($('input[name=quantity]').val()) || 1;
                let total = premium * lotSize * lots;
                $('#total_cost').text(total.toLocaleString('en-IN', { minimumFractionDigits: 2 }) + ' INR');
            }
        })(jQuery);
    </script>
@endpush
