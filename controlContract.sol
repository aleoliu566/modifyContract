pragma solidity ^0.4.25;
  
contract controlContract {
    address owner;
    struct userData {
        address userAddress;
        uint fsmVersion;
        uint currentState;
    }

    struct fsmContractDetail {
        address contractAddress;
        string functionName;
    }

    userData[] public users;
    mapping(uint => mapping(uint => mapping(uint=>uint) )) public mapFSM;
    mapping(uint => mapping(uint => fsmContractDetail)) public mapFSMDetail;
    uint public versionNumber; // FSM 目前最新的 version (已完成更新的)
    uint public updatingVersionNumber; // 正在更新的FSM version
    uint public updateTimeStamp;
    
    function () public payable {}
    constructor() payable{
        owner = msg.sender;
        updatingVersionNumber = 0;
        versionNumber = 0;
    }

    // add general user
    function addUser(address _userAddress) onlyAdmin{
        users.push(userData({
            userAddress: _userAddress,
            fsmVersion: versionNumber,
            currentState: 0
        }));
    }

    // admin user update FSM mapping
    function updateFSM(
                    bool _updateType,    // update or delete
                    uint _state,
                    uint _nextState,
                    uint _eventId,
                    string _functionName,
                    address _addressName,
                    bool _finishVersionUpdate // complete version update
                ) public onlyAdmin{
        if(updateTimeStamp != 0 && now - updateTimeStamp > 86400){ // 超過一天後的更新，或是沒有主動完成上一版本，就更新的新版本
            updatingVersionNumber = updatingVersionNumber + 1;
        }

        if(_updateType){
            mapFSMDetail[updatingVersionNumber][_state] = fsmContractDetail({contractAddress: _addressName, functionName: _functionName});
            mapFSM[updatingVersionNumber][_state][_eventId] = _nextState;
        } else {
            mapFSMDetail[updatingVersionNumber][_state] = fsmContractDetail({contractAddress: 0, functionName: ""});
            mapFSM[updatingVersionNumber][_state][_eventId] = 0;
        }
        updateTimeStamp = now;
        if(_finishVersionUpdate){ // 更新完成後，版本號+1
            updatingVersionNumber = updatingVersionNumber + 1;
            versionNumber = updatingVersionNumber - 1;
            updateTimeStamp = 0;
        }
    }

    function executeNextState(address _userAddress, uint _eventId, uint _functionParameter) public payable{
        uint fsmVersion;
        uint nextState;
        (nextState,fsmVersion) = userNextState(_userAddress, _eventId);

        string memory fsmfunction = concatString(mapFSMDetail[fsmVersion][nextState].functionName,'(address)');
        bytes4 method = bytes4(keccak256(fsmfunction));
        bool callSucceedOrNot = mapFSMDetail[fsmVersion][nextState].contractAddress.call(method, _userAddress);
        if (callSucceedOrNot){ users[getUserIdx(_userAddress)].currentState = nextState; }
    }

    function userNextState(address _addr, uint _eventId) view returns(uint, uint){
        userData user = users[getUserIdx(_addr)];
        uint fsmVersion = user.fsmVersion;
        uint currentState = user.currentState;
        uint nextState;
        if(currentState == 0){
            nextState = 1;
        } else {
            nextState = mapFSM[fsmVersion][currentState][_eventId];
        }
        return (nextState,fsmVersion);
    }

    function executeNextStatebytes(address _userAddress, uint _eventId, bytes32 _functionParameter) public payable{
        uint fsmVersion;
        uint nextState;
        (nextState,fsmVersion) = userNextState(_userAddress, _eventId);

        string memory fsmfunction = concatString(mapFSMDetail[fsmVersion][nextState].functionName,'(address,bytes32)');
        bytes4 method = bytes4(keccak256(fsmfunction));
        bool callSucceedOrNot = mapFSMDetail[fsmVersion][nextState].contractAddress.call.value(msg.value)(method, _userAddress, _functionParameter);
        if (callSucceedOrNot){ users[getUserIdx(_userAddress)].currentState = nextState; }
    }

    uint public a;
    uint public b;
    // string public c;
    function executeNextStateUint(address _userAddress, uint _eventId, uint _functionP) public payable{
        uint fsmVersion;
        uint nextState;
        (nextState,fsmVersion) = userNextState(_userAddress, _eventId);
        (a,b) = userNextState(_userAddress, _eventId);
        // c = string(abi.encodePacked(0x00000000000000000000000000000000000000000048656c6c6f20576f726c64));

        string memory fsmfunction = concatString(mapFSMDetail[fsmVersion][nextState].functionName,'(address,uint256)');
        bytes4 method = bytes4(keccak256(fsmfunction));
        bool callSucceedOrNot = mapFSMDetail[fsmVersion][nextState].contractAddress.call.value(msg.value)(method, _userAddress, _functionP);
        if (callSucceedOrNot){ users[getUserIdx(_userAddress)].currentState = nextState; }
    }


    function executeNextStatebytesbytesUint(address _userAddress, uint _eventId, bytes32 _p1, bytes32 _p2, uint _p3) public payable{
        uint fsmVersion;
        uint nextState;
        (nextState,fsmVersion) = userNextState(_userAddress, _eventId);
        
        string memory fsmfunction = concatString(mapFSMDetail[fsmVersion][nextState].functionName,'(address,bytes32,,bytes32,uint256)');
        bytes4 method = bytes4(keccak256(fsmfunction));
        bool callSucceedOrNot = mapFSMDetail[fsmVersion][nextState].contractAddress.call.value(msg.value)(method, _userAddress, _p1, _p2, _p3);
        if (callSucceedOrNot){ users[getUserIdx(_userAddress)].currentState = nextState; }
    }
    
    
    


    
    // update to the latest version
    function userUpdateFSMtoNewVersion() public onlyGeneralUser{
        uint i = getUserIdx(msg.sender);
        users[i].fsmVersion = versionNumber;
    }

    function getUserIdx(address _userAddress) public view returns(uint){
        uint index = 100000;
        for(uint i = 0; i < users.length; i++){
            if (_userAddress == users[i].userAddress){
                index = i;
            }
        }
        return index;
    }
    
    function setUserFsmVersionAndState(address _addr, uint _state) public onlyAdmin{
        
    }
    
    function compensateMoney(address _addr, uint _money) payable{
        _addr.send(_money);
    }

    function concatString(string _s1, string _s2) view returns(string) {
        bytes memory byte_s1 = bytes(_s1);
        bytes memory byte_s2 = bytes(_s2);
        
        string memory concatedString = new string(byte_s1.length + byte_s2.length);
        bytes memory bret = bytes(concatedString);
        uint k = 0;
        for (uint i = 0; i < byte_s1.length; i++)bret[k++] = byte_s1[i];
        for (i = 0; i < byte_s2.length; i++) bret[k++] = byte_s2[i];
        return concatedString;
    }

    modifier onlyAdmin() {
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyGeneralUser() {
        uint i = getUserIdx(msg.sender);
        require(i < 100000);
        _;
    }
}