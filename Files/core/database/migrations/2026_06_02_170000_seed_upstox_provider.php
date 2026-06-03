<?php

use App\Constants\Status;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        // Deactivate all existing providers
        DB::table('currency_data_providers')->update(['is_default' => Status::NO, 'status' => Status::DISABLE]);

        // Insert/Seed Upstox provider
        DB::table('currency_data_providers')->insertOrIgnore([
            'id' => 3,
            'name' => 'Upstox',
            'alias' => 'Upstox',
            'configuration' => json_encode([
                'access_token' => [
                    'title' => 'Access Token',
                    'value' => ''
                ]
            ]),
            'type' => 1, // Crypto / Stock price data type
            'status' => Status::ENABLE,
            'help' => 'Configure Upstox API credentials. Visit Upstox developer center to generate access token.',
            'image' => 'upstox.png',
            'is_default' => Status::YES,
            'instruction' => '<ul class="list-group list-group-flush"><li class="list-group-item">Go to Upstox Developer Portal</li><li class="list-group-item">Register your app and authenticate to get your access token</li><li class="list-group-item">Insert your Access Token here</li></ul>',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        DB::table('currency_data_providers')->where('id', 3)->delete();
        DB::table('currency_data_providers')->where('id', 1)->update(['is_default' => Status::YES, 'status' => Status::ENABLE]);
    }
};
