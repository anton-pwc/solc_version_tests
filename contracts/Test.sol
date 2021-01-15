pragma solidity >=0.4.0 <=0.8.0;
// SPDX-License-Identifier: UNLICENSED

contract Data256 {
    function getData() public pure returns(uint256){
        uint256 x = 115792089237316195423570985008687907853269984665640564039457584007913129639935; // 2**256 - 1
        return x;
    }
    function getData_1() public pure returns(uint256){
        uint256 x = 340282366920938463463374607431768211556; // 100 + 2**128
        return x;
    }
}

contract Data128{
    uint128 public  data;

    function getData() public pure returns(uint128){
        uint256 a = 115792089237316195423570985008687907853269984665640564039457584007913129639935; // 2**256 - 1
        uint128 x = uint128(a);
        return x;
    }

    function getData_1() public pure returns(uint128){
        return getData();
    }

    function set(uint128 value) public{
        data = value;
    }
}


contract Test{

    function address_convetion() public {
        address a = address(this);
        uint160 b = uint160(a);
        uint256 x = uint256(b);
        uint256 y;
        assembly{
            y := b
        }
        require(x == y, "CHECK");
    }

    function uint_shrink() public {
        uint256 a = 115792089237316195423570985008687907853269984665640564039457584007913129639935;
        uint128 x = uint128(a);
        uint128 y;
        assembly{
            y := a
        }
        require(x == y, "CHECK");
    }

    function uint_shrink_expand() public {
        uint256 a = 115792089237316195423570985008687907853269984665640564039457584007913129639935;
        uint128 b = uint128(a);
        uint256 x = uint256(b);
        uint256 y;
        assembly{
            y := b
        }
        // Reverts
        require(x == y, "CHECK");
    }

    function returndata_expand() public {
        Data128 ff = new Data128();
        uint128 a = ff.getData();
        uint256 x = uint256(a);
        uint256 y;
        assembly{
            y := a
        }
        require(x == y, "CHECK");
    }

    function returndata_shrink() public {
        Data256 ff = new Data256();
        uint256 a = ff.getData();
        uint128 x = uint128(a);
        uint128 y;
        assembly{
            y := a
        }
        require(x == y, "CHECK");
    }

    function returndata_convertion_dirty() public {
        Data256 f = new Data256();
        Data128 ff = Data128(address(f));
        uint128 a = ff.getData();
        uint256 x = uint256(a);
        uint256 y;
        assembly{
            y := a
        }
        require(x == y, "CHECK");
    }

    function returndata_div() public {
        Data256 f = new Data256();
        Data128 ff = Data128(address(f));
        uint128 a = ff.getData_1();
        require(a == 100, "CHECK1");
        uint256 y;
        assembly{
            y := div(a, 2)
        }
        require(y == 50, "CHECK2");
    }

    function returndata_sum() public{
        Data256 f = new Data256();
        Data128 ff = Data128(address(f));
        uint128 a = ff.getData_1();
        uint256 b = 115792089237316195423570985008687907853269984665640564039457584007913129639935;
        uint256 x = uint256(a) + b;
        uint256 y;
        assembly{
            y := add(a, b)
        }
        require(a == 100, "CHECK1");
        require(y == x, "CHECK2");
    }
    function returndata_asm_shrink() public  {
        Data256 f = new Data256();
        Data128 ff = Data128(address(f));
        address contractAddr = address(ff);  
        bytes4 sig = bytes4(keccak256("getData()")); //Function signature
        uint128 data;
        assembly {
            let x := mload(0x40)
            mstore(x,sig)
            mstore(0x40,add(x,0x64))
            let success := call(      
                            5000,
                            contractAddr,
                            0,
                            x,
                            0x04,
                            x,
                            0x10) //Output is 16 bytes long

            data := mload(x)       //Assign output value
            mstore(0x40,add(x,0x20)) // Set storage pointer to empty space
        }
        require(data == 100, "CHECK");
    }

    function dirty_calldata() public  {
        uint256 data = 340282366920938463463374607431768211556; // 2**128 + 100
        Data128 a = new Data128();
        bytes4 sig = bytes4(keccak256("set(uint128)")); //Function signature
        bool success;
        assembly {
            let x := mload(0x40)   // Free memory location
            mstore(x,sig) // Signature
            mstore(add(x,0x04),data) // first calldata parameter goes 4 bytes after
            mstore(0x40,add(x,0x24)) // Adjustring free memory pointer

            success := call(      
                            100000, //5k gas
                            a, // To addr
                            0,    // 0 wei
                            x,    // Inputs are at location x
                            0x24, // Inputs are 4 bytes sig + 32 bytes data
                            x,    // Pointer to store return data
                            0x0) //Output is 32 bytes long
        }
        require(success);
    }


    function asm_returndata() public  {
        Data256 f = new Data256();
        Data128 ff = Data128(address(f));
        address contractAddr = address(ff);  
        bytes4 sig = bytes4(keccak256("getData_1()")); //Function signature
        uint256 data;
        assembly {
            let x := mload(0x40)
            mstore(x,sig)
            mstore(0x40,add(x,0x64))
            let success := call(      
                            5000,
                            contractAddr,
                            0,
                            x,
                            0x04,
                            x,
                            0x20) //Output is 32 bytes long !!!

            data := mload(x)       //Assign output value
            mstore(0x40,add(x,0x20)) // Set storage pointer to empty space
        }
        require(data == 340282366920938463463374607431768211556, "CHECK");
    }

    function asm_returndata_expand() public  {
        Data256 f = new Data256();
        Data128 ff = Data128(address(f));
        address contractAddr = address(ff);  
        bytes4 sig = bytes4(keccak256("getData()")); //Function signature
        uint256 data;
        assembly {
            let x := mload(0x40)
            mstore(x,sig)
            mstore(0x40,add(x,0x64))
            let success := call(      
                            5000,
                            contractAddr,
                            0,
                            x,
                            0x04,
                            x,
                            0x10) //Output is 16 bytes long !!!

            data := mload(x)
            mstore(0x40,add(x,0x20))
        }
        require(data == 100, "CHECK");
    }

    function asm_returndata_shrink() public  {
        Data256 f = new Data256();
        Data128 ff = Data128(address(f));
        address contractAddr = address(ff);  
        bytes4 sig = bytes4(keccak256("getData_1()")); //Function signature
        uint128 data;
        assembly {
            let x := mload(0x40)
            mstore(x,sig)
            mstore(0x40,add(x,0x64))
            let success := call(      
                            5000,
                            contractAddr,
                            0,
                            x,
                            0x04,
                            x,
                            0x20) //Output is 32 bytes long

            data := mload(x)       //Assign output value
            mstore(0x40,add(x,0x20)) // Set storage pointer to empty space
        }
        require(data == 100, "CHECK");
    }

}
