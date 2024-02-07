
function intSize(uint64 i) pure returns (uint256 _size) {
    if (i < 0x10) {
        return 1;
    } else if (i < 0x1000) {
        return 2;
    } else if (i < 0x100000) {
        return 3;
    } else if (i < 0x10000000) {
        return 4;
    } else if (i < 0x1000000000) {
        return 5;
    } else if (i < 0x100000000000) {
        return 6;
    } else if (i < 0x10000000000000) {
        return 7;
    } else if (i < 0x1000000000000000) {
        return 8;
    } else {
        revert("out of bound");
    }
}

function putint(uint64 i) pure returns (bytes memory _data, uint256 _size) {
    if (i < 0x10) {
        _size = 1;
        _data = new bytes(_size);
        _data[0] = bytes1(uint8(i));
    } else if (i < 0x1000) {
        _size = 2;
        _data = new bytes(_size);
        _data[0] = bytes1(uint8(i >> 8));
        _data[1] = bytes1(uint8(i));
    } else if (i < 0x100000) {
        _size = 3;
        _data = new bytes(_size);
        _data[0] = bytes1(uint8(i >> 16));
        _data[1] = bytes1(uint8(i >> 8));
        _data[2] = bytes1(uint8(i));
    } else if (i < 0x10000000) {
        _size = 4;
        _data = new bytes(_size);
        _data[0] = bytes1(uint8(i >> 24));
        _data[1] = bytes1(uint8(i >> 16));
        _data[2] = bytes1(uint8(i >> 8));
        _data[3] = bytes1(uint8(i));
    } else if (i < 0x1000000000) {
        _size = 5;
        _data = new bytes(_size);
        _data[0] = bytes1(uint8(i >> 32));
        _data[1] = bytes1(uint8(i >> 24));
        _data[2] = bytes1(uint8(i >> 16));
        _data[3] = bytes1(uint8(i >> 8));
        _data[4] = bytes1(uint8(i));
    } else if (i < 0x100000000000) {
        _size = 6;
        _data = new bytes(_size);
        _data[0] = bytes1(uint8(i >> 40));
        _data[1] = bytes1(uint8(i >> 32));
        _data[2] = bytes1(uint8(i >> 24));
        _data[3] = bytes1(uint8(i >> 16));
        _data[4] = bytes1(uint8(i >> 8));
        _data[5] = bytes1(uint8(i));
    } else if (i < 0x10000000000000) {
        _size = 7;
        _data = new bytes(_size);
        _data[0] = bytes1(uint8(i >> 48));
        _data[1] = bytes1(uint8(i >> 40));
        _data[2] = bytes1(uint8(i >> 32));
        _data[3] = bytes1(uint8(i >> 24));
        _data[4] = bytes1(uint8(i >> 16));
        _data[5] = bytes1(uint8(i >> 8));
        _data[6] = bytes1(uint8(i));  
    } else if (i < 0x1000000000000000) {
        _size = 8;
        _data = new bytes(_size);
        _data[0] = bytes1(uint8(i >> 56));
        _data[1] = bytes1(uint8(i >> 48));
        _data[2] = bytes1(uint8(i >> 40));
        _data[3] = bytes1(uint8(i >> 32));
        _data[4] = bytes1(uint8(i >> 24));
        _data[5] = bytes1(uint8(i >> 16));
        _data[6] = bytes1(uint8(i >> 8));
        _data[7] = bytes1(uint8(i));
    } else {
        revert("out of bound");
    }
}

library RLPEncode {
    using RLPEncode for bytes;

    function encodeAddress(bytes memory _buf, address _addr) internal returns(bytes memory) {
        return  abi.encodePacked(_buf, uint8(0x80 + 20), _addr);
    }

    function encodeUint64(bytes memory _buf, uint64 _n) internal returns(bytes memory) {
        if (_n == 0) {
            return abi.encodePacked(_buf, uint8(0x80));
        } else if (_n < 0x80) {
            return abi.encodePacked(_buf, uint8(_n));
        } else {
            (bytes memory _data, uint256 _size) = putint(_n);
            return abi.encodePacked(_buf, abi.encodePacked(uint8(0x80 + uint8(_size)), _data));
        }
    }
}