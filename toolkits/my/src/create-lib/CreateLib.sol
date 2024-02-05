import {Test, console2} from "hello-fs/Test.sol";

import {RLPEncode, intSize} from "../crypto/RLPEncode.sol";

library CreateLib {
    using  RLPEncode for bytes;

    function createAddress(address _creator, uint64 _nonce) internal returns(address) {
        bytes memory _buf = new bytes(0);

        uint _size = intSize(_nonce);
        _buf = abi.encodePacked(_buf, uint8(0xc0 + 21 + _size));
        _buf = _buf.encodeAddress(_creator).encodeUint64(_nonce);

        return address(uint160(uint256(keccak256(_buf))));
    }
}


contract CreateLibTest is Test {
    function test_create_address() public {
        address _c = 0x1234567891234567891234567891234567891234;
        uint256 _n = 0;
        address _res = CreateLib.createAddress(_c, uint64(_n));
        console2.log("%s (nonce=%s) create: %s", _c, _n, _res);

        assertEq(_res, 0x0BD5f929B456Ca8Af11Ebe2CE4eB117395AF3b69);
    }
}