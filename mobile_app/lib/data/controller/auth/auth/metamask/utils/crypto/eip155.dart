


enum EIP155UIMethods {
  personalSign,
  ethSignTypedDataV4,
  ethSendTransaction,
  requestAccounts,
  ethSignTypedDataV3,
  ethSignTransaction,
  walletWatchAsset;

  String get name {
    switch (this) {
      case personalSign:
        return 'personal_sign';
      case ethSignTypedDataV4:
        return 'eth_signTypedData_v4';
      case ethSendTransaction:
        return 'eth_sendTransaction';
      case requestAccounts:
        return 'eth_requestAccounts';
      case ethSignTypedDataV3:
        return 'eth_signTypedData_v3';
      case ethSignTransaction:
        return 'eth_signTransaction';
      case walletWatchAsset:
        return 'wallet_watchAsset';
    }
  }
}

class EIP155 {
  static EIP155UIMethods methodFromName(String name) {
    switch (name) {
      case 'personal_sign':
        return EIP155UIMethods.personalSign;
      case 'eth_signTypedData_v4':
        return EIP155UIMethods.ethSignTypedDataV4;
      case 'eth_sendTransaction':
        return EIP155UIMethods.ethSendTransaction;
      case 'eth_requestAccounts':
        return EIP155UIMethods.requestAccounts;
      case 'eth_signTypedData_v3':
        return EIP155UIMethods.ethSignTypedDataV3;
      case 'eth_signTransaction':
        return EIP155UIMethods.ethSignTransaction;
      case 'wallet_watchAsset':
        return EIP155UIMethods.walletWatchAsset;
      default:
        throw Exception('Unrecognized method');
    }
  }
}