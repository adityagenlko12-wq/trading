<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('option_contracts', function (Blueprint $table) {
            $table->id();
            $table->string('underlying_symbol', 55);
            $table->string('instrument_key', 100)->unique();
            $table->decimal('strike_price', 28, 8);
            $table->enum('option_type', ['CE', 'PE']);
            $table->date('expiry_date');
            $table->integer('lot_size')->default(1);
            $table->decimal('last_price', 28, 8)->default(0);
            $table->tinyint('status')->default(1);
            $table->timestamps();
        });

        Schema::create('option_positions', function (Blueprint $table) {
            $table->id();
            $table->bigInteger('user_id')->unsigned();
            $table->bigInteger('contract_id')->unsigned();
            $table->integer('quantity'); // Positive for Long, negative for Short
            $table->decimal('average_price', 28, 8);
            $table->decimal('unrealized_pnl', 28, 8)->default(0);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('option_positions');
        Schema::dropIfExists('option_contracts');
    }
};
