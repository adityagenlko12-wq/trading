<?php

namespace App\Models;

use App\Traits\GlobalStatus;
use Illuminate\Database\Eloquent\Model;

class OptionContract extends Model
{
    use GlobalStatus;

    protected $guarded = ['id'];

    public function positions()
    {
        return $this->hasMany(OptionPosition::class, 'contract_id');
    }
}
