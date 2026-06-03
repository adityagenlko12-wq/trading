<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class OptionPosition extends Model
{
    protected $guarded = ['id'];

    public function contract()
    {
        return $this->belongsTo(OptionContract::class, 'contract_id');
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}
