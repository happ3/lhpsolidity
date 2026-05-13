// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract testStruct {

    struct Student{
        uint age;
        string id;
        string name;
    }

    Student public  stu;
    
    function setStudent(uint _age,string calldata _id,string calldata _name)public  {
        stu.age= _age;
        stu.id=_id;
        stu.name=_name;
    }

}