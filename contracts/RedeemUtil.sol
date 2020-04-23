pragma solidity ^0.6.1;
pragma experimental ABIEncoderV2;

library RedeemUtil {
  struct Redeem {
    uint256 blockNumber;
    bytes32 blockHash;
    address receiver;
    bytes32 code;
  }

  bytes32 constant REDEEM_TYPEHASH = keccak256("Redeem(uint256 blockNumber,bytes32 blockHash,address receiver,bytes32 code)");

  function getChainID() internal pure returns (uint256) {
    uint256 id;
    assembly {
      id := chainid()
    }

    return id;
  }

  function validateExpiryDate(uint256 _expirationTime) internal view {
    require(_expirationTime > block.timestamp, "expiration can't be in the past");
  }

  function validateExpired(uint256 _expirationTime) internal view {
    require(block.timestamp >= _expirationTime, "not expired yet");
  }

  function validateRedeem(Redeem memory _redeem, uint256 _maxTxDelayInBlocks, uint256 _expirationTime, uint256 _startTime) internal view {
    require(_redeem.blockNumber < block.number, "transaction cannot be in the future");
    require(_redeem.blockNumber >= (block.number - _maxTxDelayInBlocks), "transaction too old");
    require(_redeem.blockHash == blockhash(_redeem.blockNumber), "invalid block hash");

    require(block.timestamp < _expirationTime, "expired gift");
    require(block.timestamp > _startTime, "reedeming not yet started");
  }

  function hashRedeem(Redeem memory _redeem) internal pure returns (bytes32) {
    return keccak256(abi.encode(
      REDEEM_TYPEHASH,
      _redeem.blockNumber,
      _redeem.blockHash,
      _redeem.receiver,
      _redeem.code
    ));
  }

  function recoverSigner(bytes32 _domainSeparator, Redeem memory _redeem, bytes memory _sig) internal pure returns(address) {
    require(_sig.length == 65, "bad signature length");

    bytes32 r;
    bytes32 s;
    uint8 v;

    assembly {
      r := mload(add(_sig, 32))
      s := mload(add(_sig, 64))
      v := byte(0, mload(add(_sig, 96)))
    }

    if (v < 27) {
      v += 27;
    }

    require(v == 27 || v == 28, "signature version doesn't match");

    bytes32 digest = keccak256(abi.encodePacked(
        "\x19\x01",
        _domainSeparator,
        hashRedeem(_redeem)
    ));

    return ecrecover(digest, v, r, s);
  }

  function validateCode(Redeem memory _redeem, bytes32 _code) internal pure {
    bytes32 codeHash = keccak256(abi.encodePacked(_redeem.code));
    require(codeHash == _code, "invalid code");
  }
}