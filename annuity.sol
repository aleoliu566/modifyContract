pragma solidity ^0.4.25;

contract Annuity {
    address public storage_contract;
    storageContract sc;
    FaceData fd;
    
    // 位址、年金費用、身分證字號、時間
    event annuityTx(address _addr, uint _value, string _id, uint _date);

    constructor() payable{
        setInsuranceData();
        setInsuranceData2();
    }
    // 設定storage contract
    function setStorageContract(address _storage_contract) public {
        storage_contract = _storage_contract;
        sc = storageContract(storage_contract);
    }

    // 設定FaceData contract
    function setFaceContract(address _face_contract) public {
        fd = FaceData(_face_contract);
    }

    // 設定使用者資料
    function setuserData(address _addr, bytes32 _userName, bytes32 _userId, uint _birth) public {
        string memory name = string(abi.encodePacked(_userName));
        string memory id = string(abi.encodePacked(_userId));
        
        sc.setUser(_addr,name,id,_birth);
    }

    // 使用者選擇年金方案
    uint public a;
    uint[] public programEther = [0, 100000, 200000, 300000]; //  program => 0 1 2 3
    function selectProgram(address _addr, uint _program) public payable{
        a = _program;
        sc.setProgram(_addr, _program);
    }

    function selectQuantity(address _addr, uint _amount) public payable{
        sc.setUserbuyQuantity(_addr, _amount);
    }
    
    // 要保人付費，去storage拿出來，再傳進去一次
    // 智能合約應該沒辦法直接更新其他智能合約裡面的值，除非他有寫好function給別的contract呼叫
    function userPayEtherToCompany(address _addr) public payable{
        uint _program = sc.usersProgram(_addr);
        sc.setUserpayEther(_addr, msg.value);
        if (sc.usersPayValue(_addr) >= programEther[_program]){
            sc.setUserpayEnough(_addr);
        }
    }

    function userPayEtherToCompany2(address _addr, uint _age) public payable{
        uint _program = sc.usersProgram(_addr);
        uint usersAmount = sc.usersAmount(_addr);
        sc.setUserpayEther(_addr, msg.value);
        if (sc.usersPayValue(_addr) >= insuranceData[_program][_age] * usersAmount){
            sc.setUserpayEnough(_addr);
        }
    }

    // 公司付年金
    function companyPayMonthly(address _addr) public payable{
        uint program = sc.usersProgram(_addr);
        uint ammount = sc.usersAmount(_addr);
        uint ann = 1000;
        if(program == 1){ //年領轉月領
            ann = 83; // (insuranceData[1][45] / insuranceData[2][45]) * ammount;
        }
        ann = ann * ammount;
        _addr.transfer(ann);
        sc.companyPayAnnuity(_addr, ann);
        emit annuityTx(_addr, ann, sc.usersId(_addr), now);

        // if(sc.usersPayEnough(_addr) && (now - sc.usersAnnuityPayTime(_addr) >= 10)){
        //     // 還需要去計算上次領取跟這次領取差多少時間，差一年給12萬，差兩年給24萬
        //     _addr.transfer(1000);
        //     sc.companyPayAnnuity(_addr, 1000);
        //     emit annuityTx(_addr, 1000, sc.usersId(_addr), now);
        // }
    }

    function companyPayAnnual(address _addr) public payable{
        uint program = sc.usersProgram(_addr);
        uint ammount = sc.usersAmount(_addr);
        uint ann = 1000;
        if(program == 2){ //年領轉月領
            ann = 1000*12; // (insuranceData[1][45] / insuranceData[2][45]) * ammount;
        }
        ann = ann * ammount;
        _addr.transfer(ann);
        sc.companyPayAnnuity(_addr, ann);
        emit annuityTx(_addr, ann, sc.usersId(_addr), now);

        // if(sc.usersPayEnough(_addr) && (now - sc.usersAnnuityPayTime(_addr) >= 10)){
        //     // 還需要去計算上次領取跟這次領取差多少時間，差一年給12萬，差兩年給24萬
        //     _addr.transfer(1000);
        //     sc.companyPayAnnuity(_addr, 1000);
        //     emit annuityTx(_addr, 1000, sc.usersId(_addr), now);
        // }
    }

    function companyPayBasic(address _addr) public payable{
        uint program = sc.usersProgram(_addr);

        // if(sc.usersPayEnough(_addr) && (now - sc.usersAnnuityPayTime(_addr) >= 10)){
            // 還需要去計算上次領取跟這次領取差多少時間，差一年給12萬，差兩年給24萬
            _addr.transfer(1000*program);
            sc.companyPayAnnuity(_addr, 1000*program);
            emit annuityTx(_addr, 1000*program, sc.usersId(_addr), now);
        // }
    }
    
    // 被保人過世
    function userGone(address _addr) public{
        sc.userContractTerminate(_addr);
    }
    
    // 要保人後悔
    function regretOrNot(address _addr) public{
        if(now - sc.usersJoinTime(_addr) < 10 days){
            _addr.transfer(sc.usersPayValue(_addr));
            sc.userContractTerminate(_addr);
        }
    }

    mapping(uint => mapping(uint=>uint)) public insuranceData;
    function setInsuranceData() public {
        // program, age
        insuranceData[1][45] = 28425;
        insuranceData[1][46] = 28031;
        insuranceData[1][47] = 27634;
        insuranceData[1][48] = 27234;
        insuranceData[1][49] = 26829;
        insuranceData[1][50] = 26421;
        insuranceData[1][51] = 26010;
        insuranceData[1][52] = 25595;
        insuranceData[1][53] = 25177;
        insuranceData[1][54] = 24756;
        insuranceData[1][55] = 24332;
        insuranceData[1][56] = 23906;
        insuranceData[1][57] = 23478;
        insuranceData[1][58] = 23047;
        insuranceData[1][59] = 22615;
        insuranceData[1][60] = 22182;
        insuranceData[1][61] = 21747;
        insuranceData[1][62] = 21312;
        insuranceData[1][63] = 20877;
        insuranceData[1][64] = 20433;
        insuranceData[1][65] = 20008;
    }

    function setInsuranceData2() public {
        insuranceData[2][45] = 348833;
        insuranceData[2][46] = 344136;
        insuranceData[2][47] = 339391;
        insuranceData[2][48] = 334600;
        insuranceData[2][49] = 329763;
        insuranceData[2][50] = 324883;
        insuranceData[2][51] = 319960;
        insuranceData[2][52] = 314997;
        insuranceData[2][53] = 309994;
        insuranceData[2][54] = 304954;
        insuranceData[2][55] = 299878;
        insuranceData[2][56] = 294770;
        insuranceData[2][57] = 289631;
        insuranceData[2][58] = 284465;
        insuranceData[2][59] = 279274;
        insuranceData[2][60] = 274063;
        insuranceData[2][61] = 268839;
        insuranceData[2][62] = 263603;
        insuranceData[2][63] = 258361;
        insuranceData[2][64] = 253117;
        insuranceData[2][65] = 247875;
    }
    
    function getInsuranceData(uint program, uint age) public view returns(uint){
        return insuranceData[program][age];
    }


    // 其他函式
    function returnProgramEtherArray() public view returns(uint[]) {
        return programEther;
    }

    function getBalance(address _addr) public view returns (uint) {
        return address(_addr).balance; // this
    }
    
    // function getUserProgram (address _addr) public constant returns (address, string, uint, uint, uint, uint, uint, bool, bool, uint, uint){
    //     sc.usersData(_addr);
    //     return sc.usersData(_addr);
    // }
    
    // 限制式
    modifier userAlive() {
        // require(usersData[msg.sender].live == true);
        _;
    }
}

contract storageContract {
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
    
    function setUser(address _addr, string _userName, string _userId, uint _birth) public {}
    function setProgram(address _addr, uint _program) public {}
    function setUserpayEther(address _addr, uint _value) public {}
    function setUserpayEnough(address _addr) public {}
    function userContractTerminate(address _addr) public {}
    function companyPayAnnuity(address _addr, uint _val) public {}
    function setUserbuyQuantity(address _addr, uint _ammount) public {}
}


contract FaceData{
    mapping(address => int[]) userFace;

    function getUserFace(address _addr) public view returns(int[]){
        return userFace[_addr];
    }
}