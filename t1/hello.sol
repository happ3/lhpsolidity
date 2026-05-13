// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
contract HelloWeb3{
    string public str = "Hello Web3!";

    // bytes32 public byteVsl = "Hello World!";

    // uint256 intVal =123;
    // address addVal = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    struct Info{
        string phrase;
        uint256 id;
        address addr;
    }

    Info []infos;
    mapping(uint256 id => Info info) infoMapping;

    function sayHello(uint256 id) public view  returns  (string memory){
        if (infoMapping[id].addr == address(0x0) ){
            return addinfo(str);
        }else{
            return addinfo(infoMapping[id].phrase);
        }
         


        // for (uint256 i = 0 ; i < infos.length; i++)         {
        //     if (infos[i].id == id){
        //         return addinfo(infos[i].phrase);
        //     }
        // }
        // return addinfo(str);
    }

    function sayHelloWorld(string memory newString ,uint256 id)public {
        Info memory info = Info(newString,id,msg.sender);
        infoMapping[id] = info;
        // infos.push(info);
    }


    function modifyVal  (string memory varStr)public{
        str = varStr;
    }

    function addinfo (string memory helloStr) internal  pure  returns (string memory){
        return string.concat(helloStr, " so beautiful");
    }

}
