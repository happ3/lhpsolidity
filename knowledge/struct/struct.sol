// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

//["晓东","男",18,[["乒乓球","圆形"]]]
contract Dome {
    struct Person {
        string name;
        string sex;
        uint age;
        Hoppy[] hoppy;
    }

    struct Hoppy {
        string hoppyName;
        string desc;
    }

    Person[] public personList;

    function addPerson(Person calldata person) public {
        personList.push(person);
    }

    function readPersonList() public view returns (Person[] memory) {
        return personList;
    }

    mapping(address account => Person Person) public personMap;

//0xa3A518Ba4e193Fb129aa379F5916d4660f15cE5D  这个是一个对象的值 ： ["晓东","男",18,[["乒乓球","圆形"]]]
    function setMap(address addr, Person calldata pseson) public {
        personMap[addr] = pseson;
    }
}
