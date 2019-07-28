pragma solidity ^0.4.25;

contract Storage {
    address owner;
    // mapping(address => uint) public usersProgram;
    // mapping(address => uint) public usersContinent;

    // struct userInfo {
        // address userAddress;
        // string userName;
        // uint userId;       // 身份證字號
        // uint joinTime;       
        // uint birthDay;     // 生日
        // uint program;        // 選擇方案
        // uint payEther;       
        // bool payEnough;      
        // bool live;           // 是否活著
        // uint annuityRecieve; // 收到的年金
        // uint annuityPayTime; // 上次收取年金的時間
    // }
    // mapping(address => userInfo) public usersData;

    address[] public usersAddress;
    
    mapping(address => string) public usersName;
    mapping(address => string) public usersId;
    mapping(address => uint) public usersBirth;
    mapping(address => uint) public usersProgram;
    mapping(address => uint) public usersAmount;
    mapping(address => uint) public usersJoinTime;  // 要保人加入時間
    mapping(address => uint) public usersPayValue;  // 繳交的保險費用
    mapping(address => bool) public usersPayEnough; // 是否繳交足夠保費
    mapping(address => bool) public usersLive;      // 要保人是否活著
    mapping(address => uint) public usersAnnuityRecieve;  // 被保人收到的年金
    mapping(address => uint) public usersAnnuityPayTime; // 上次收取年金的時間

    constructor() public{
        owner = msg.sender;
    }
    
    function setUser(address _addr, string _userName, string _userId, uint _birth) public {
        // usersData[_addr] = userInfo({
        //     userAddress: _addr,
        //     userName: _userName,
        //     userId: _userId,
        //     // joinTime: now,
        //     birthDay: _birth,
        //     program: 0,
        //     payEther: 0,
        //     payEnough: false,
        //     live: true,
        //     annuityRecieve: 0,
        //     annuityPayTime: 0
        // });

        usersAddress.push(_addr);
        usersName[_addr] = _userName;
        usersId[_addr] = _userId;
        usersBirth[_addr] = _birth;
        usersProgram[_addr] = 0;
        usersAmount[_addr] = 0;
        usersJoinTime[_addr] = now;
        usersPayValue[_addr] = 0;
        usersPayEnough[_addr] = false;
        usersLive[_addr] = true;
        usersAnnuityRecieve[_addr] = 0;
        usersAnnuityPayTime[_addr] = 0;
    }
    
    function setProgram(address _addr, uint _program) public {
        usersProgram[_addr] = _program;
        // usersData[_addr].program = _program;
    }

    function setUserbuyQuantity(address _addr, uint _ammount) public {
        usersAmount[_addr] = _ammount;
    }
    
    function setUserpayEther(address _addr, uint _value) public {
        usersPayValue[_addr] += _value;
    }
    
    function setUserpayEnough(address _addr) public {
        usersPayEnough[_addr] = true;
    }
    
    function companyPayAnnuity(address _addr, uint _val) public {
        usersAnnuityRecieve[_addr] += _val;
        usersAnnuityPayTime[_addr] = now;
    }
    
    // 合約終止
    function userContractTerminate(address _addr) public {
        usersLive[_addr] = false;
        usersPayEnough[_addr] = false;
        usersPayValue[_addr] = 0;
    }



    uint256 public a;
    string public b="Micheal";
    bytes public c;
    string public x;
    address public d;
    int[] public tt;
    // function setName(string nn,bytes32 ss) public {
    // function setName(uint256 num, string nn, bytes32 zz, address _addr) public {
    function setName(int8[] _a) public {
        tt = _a;
        // b = nn;
        // c = ss;
        // c = bytes(nn);
        // x = string(abi.encodePacked(ss));
        // x = string(c);
        // d = _addr;
    }

    // 取得保險合約的所有位址
    function returnArray() public view returns(address[]) {
        return usersAddress;
    }
    
    // function getUserData(address _addr) public view returns(address,string,uint,uint,
    //                                                         uint,uint,uint,bool,bool,uint,uint){
    //     return (_addr,
    //             usersName[_addr],
    //             usersId[_addr],
    //             usersBirth[_addr],
    //             usersProgram[_addr],
    //             usersJoinTime[_addr],
    //             usersPayValue[_addr],
    //             usersPayEnough[_addr],
    //             usersLive[_addr],
    //             usersAnnuityRecieve[_addr],
    //             usersAnnuityPayTime[_addr]
    //     );
    // }
    
    modifier onlyAdmin() {
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyMainContract() {
        // require(msg.sender == mainContract);
        _;
    }
}