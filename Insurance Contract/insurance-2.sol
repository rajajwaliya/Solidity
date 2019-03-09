pragma solidity ^0.5.1;

contract Project{
    
    struct UserStruct {
        string Details;
        address UserAddress;
        address ProjectAddress;
        bool Exist;
    }
    
    struct InvestorStruct {
        string Details;
        address InvestorAddress;
        address ProjectAddress;
        bool Exist;
    }
    
    struct ProjectStruct {
        string Details;
        address ProjectOwner;
        address ProjectAddress;
    }
    
    mapping (uint => UserStruct) UserDetails;
    mapping (uint => InvestorStruct) InvestorDetails;
    mapping (address => ProjectStruct) ProjectDetails;
    
    //maping for check user or Inverstor alredy exist for perticular project;
    mapping( address => mapping (address => bool)) IsUserExists;
    mapping( address => mapping (address => bool)) IsInvestorExists;
    
    event UserInfo(uint id,string userdetails,address user,address project);
    event InvestorInfo(uint id,string Inverstordetails,address Inverstor,address project);
    event ProjectInfo(string Details, address Owner, address Project);
    
    modifier OnlyUser(uint userId){
        require(UserDetails[userId].UserAddress==msg.sender,"Owner Not Match ");
        _;
    }
    
    modifier OnlyProjectOwner(address ProjectAddress){
        require(ProjectDetails[ProjectAddress].ProjectOwner == msg.sender,"Owner Not Match ");
        _;
    }
    
    modifier OnlyInvestor(uint InverstorId){
        require(InvestorDetails[InverstorId].InvestorAddress == msg.sender,"Owner Not Match ");
        _;
    }
    
    function setProjectDetials(string memory Details, address ProjectAddress) public{
        require(!(ProjectDetails[ProjectAddress].ProjectAddress==ProjectAddress),"Project Address Alredy Available");
        
        ProjectDetails[ProjectAddress]=ProjectStruct(Details,msg.sender,ProjectAddress);
        emit ProjectInfo(Details,msg.sender,ProjectAddress);
    }
    
    function setUserDetials(uint8 userId, string memory Details, address ProjectAddress) public{
        require(ProjectDetails[ProjectAddress].ProjectAddress == ProjectAddress,"Project Address not valid");
        require(!UserDetails[userId].Exist,"User id Alredy Available");
        require(!IsUserExists[msg.sender][ProjectAddress],"User Alredy Available");
        
        UserDetails[userId]=UserStruct(Details,msg.sender,ProjectAddress,true);
        IsUserExists[msg.sender][ProjectAddress]=true;
        emit UserInfo(userId,Details,msg.sender,ProjectAddress);
    }
    
    function setInvestorDetials(uint8 investorId, string memory Details, address ProjectAddress) public{
        require(ProjectDetails[ProjectAddress].ProjectAddress == ProjectAddress,"Project Address not valid");
        require(!InvestorDetails[investorId].Exist,"Investor Id Alredy Available");
        require(!IsInvestorExists[msg.sender][ProjectAddress],"Investor Alredy Available");
        
        InvestorDetails[investorId]=InvestorStruct(Details,msg.sender,ProjectAddress,true);
        IsInvestorExists[msg.sender][ProjectAddress]=true;
        emit InvestorInfo(investorId,Details,msg.sender,ProjectAddress);
    }
    
    function deleteProjectDetials(address ProjectAddress) public OnlyProjectOwner(ProjectAddress) returns(bool success){
        require(ProjectDetails[ProjectAddress].ProjectAddress==ProjectAddress,"Project Address Not Available");
        delete ProjectDetails[ProjectAddress];
        return true;
    }
    
    function deleteUserDetials(uint userId) public OnlyUser(userId) returns(bool success){
        require(IsUserExists[msg.sender][UserDetails[userId].ProjectAddress],"User Not Available");
        delete UserDetails[userId];
        IsUserExists[msg.sender][UserDetails[userId].ProjectAddress]=false;
        return true;
    }
    
    function deleteInvestorDetials(uint investorId) public OnlyInvestor(investorId) returns(bool success){
        require(IsInvestorExists[msg.sender][InvestorDetails[investorId].ProjectAddress],"User Not Available");
        delete InvestorDetails[investorId];
        IsInvestorExists[msg.sender][InvestorDetails[investorId].ProjectAddress]=false;
        return true;
    }
    
    function getUserDetails(uint userId) public view returns(string memory Details, address User, address ProjectAddress){
        return(UserDetails[userId].Details,UserDetails[userId].UserAddress,UserDetails[userId].ProjectAddress);
    }
    
    function getInvestorDetails(uint investorId) public view returns(string memory Details, address Investor, address ProjectAddress){
        return(InvestorDetails[investorId].Details,InvestorDetails[investorId].InvestorAddress,InvestorDetails[investorId].ProjectAddress);
    }
    
    function getProjectDetails(address ProjectAddress) public view returns(string memory Details, address Owner){
        return(ProjectDetails[ProjectAddress].Details, ProjectDetails[ProjectAddress].ProjectOwner);
    }
}