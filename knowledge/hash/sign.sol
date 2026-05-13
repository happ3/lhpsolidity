// SPDX-License-Identifier: MIT
pragma solidity ^0.8;


/**
0，message 签名
1，hash（message）
2,sign (hash(message)，private key)|offchain
3，ecrecover(hash(message),sign)==signer

*/
contract VerifySig {


    function verify(address _signer, string memory _message, bytes memory _sig) external pure returns (bool) {
        bytes32 messageHash = getMessageHash(_message);
        bytes32 signMessageHash = getSignMessageHash(messageHash);
        address recovered = recover(signMessageHash, _sig);
        return recovered == _signer;
    }

    

    function getMessageHash(string memory _message)public pure returns (bytes32){
        return keccak256(abi.encodePacked(_message));
    }
    function getSignMessageHash(bytes32 _messageHash)public pure returns (bytes32){
         return keccak256(abi.encodePacked("str",_messageHash));
    }

    function recover(bytes32  signMessageHash,bytes memory _sig) public pure returns(address){
        (bytes32 r,bytes32 s,uint8 v) = _split(_sig);
        return ecrecover(signMessageHash, v, r, s);
    }

    function _split(bytes memory _sig)internal  pure returns (bytes32 r,bytes32 s,uint8 v)  {
        assembly{
            r := mload(add(_sig,32))
            s := mload(add(_sig,64))
            v := byte(0,mload(add(_sig,96)))
        }
    }


}