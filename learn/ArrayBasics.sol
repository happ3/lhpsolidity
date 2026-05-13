// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract ArrDome {

    //创建动态数组
    uint256[] arr;

   // 添加元素（仅动态数组可用）
    function addArr(uint256 _val)external  {
        arr.push(_val);
    }
// 获取动态数组长度
    function getLen()external view  returns (uint256) {
        return arr.length;
    }
// 删除最后元素
    function pop ()external    {
         arr.pop();
    }

// 获取整个数组
    function getArr()external view returns (uint256[] memory) {
        return arr;
    }

// 更新指定元素
    function update(uint256 _index,uint256 val) external {
        arr[_index]=val;
    }
// delete的效果
    function del(uint256 _index)external  {
        delete arr[_index];
    }

    //忽略数组排序方式 删除指定数组元素 缩短长度
    function delShort(uint256 _index)external returns (uint256[] memory) {
        uint256 len = arr.length;
        for (uint256 i=0;i<len;i++){
            arr[_index]=arr[len-1];
        }
        arr.pop();
        return arr;
    }

    //指定下标删除数组，数组缩短，要求顺序不能乱 [1,2,3,4,5]
    function delShortageByNum(uint256 _index)external returns (uint256[] memory) {
        uint256 len = arr.length;
        for (uint256 i=_index;i<len-1;i++){
            arr[i]=arr[i+1];
        }
        arr.pop();
        return arr;
    }


}














