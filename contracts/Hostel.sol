// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Hostel {
  // hostel personels
  address payable tenant;
  address payable landlord;
  uint public no_of_rooms = 0;
  uint public no_of_agreements = 0;
  uint public no_of_rent = 0;

  // hostel details
  struct Room{
    uint roomid;
    uint agreementid;
    string roomname;
    string roomaddress;
    uint rent_per_month;
    uint security_deposit;
    uint timestamp;
    bool vacant;
    address payable landlord;
    address payable currentTenant;
  }
  
  mapping (uint => Room) public Room_by_No;

    struct RoomAgreement {
    uint roomid;
    uint agreementid;
    string Roomname;
    string RoomAdress;
    uint rent_per_month;
    uint securityDeposit;
    uint lockInPeriod;
    uint timestamp;
    address payable tenantAdress;
    address payable landlordAdress;
  }

  mapping(uint => RoomAgreement) public RoomAgreement_by_No;

  struct Rent {
    uint rentno;
    uint roomid;
    uint agreementid;
    string Roomname;
    string RoomAdress;
    uint rent_per_month;
    uint timestamp;
    address payable tenantAdress;
    address payable landlordAdress;
  }

  mapping (uint => Rent) public Rent_by_No;

  modifier onlyLandlord(uint _index) {
    require(msg.sender == Room_by_No[_index].landlord, "Only landlord can access this!");
    _;
  }

  modifier notLandlord(uint _index) {
    require(msg.sender != Room_by_No[_index].landlord, "Only Tenant can access this!");
    _;
  }

  modifier onlyWhileVacant(uint _index) {
    require(Room_by_No[_index].vacant == true, "Room is currently occupied!");
    _;
  }

  modifier enoughRent(uint _index) {
    require(msg.value >= uint(Room_by_No[_index].rent_per_month), "Not enough ether in your wallet!");
    _;
  }

  modifier enoughAgreementFee(uint _index) {
    require(msg.value >= uint(Room_by_No[_index].rent_per_month) + uint(Room_by_No[_index].security_deposit), "Not enough ether in your wallet!");
    _;
  }

  modifier sameTenant(uint _index) {
    require(msg.sender == Room_by_No[_index].currentTenant, "No previous agreement found with you & landlord!");
    _;
  }

  modifier agreementTimeLeft(uint _index) {
    uint _AgreementNo = Room_by_No[_index].agreementid;
    uint time = RoomAgreement_by_No[_AgreementNo].timestamp + RoomAgreement_by_No[_AgreementNo].lockInPeriod;
    require(now < time, "Agreement already ended!");
    _;
  }

  modifier agreementTimeUp(uint _index) {
    uint _AgreementNo = Room_by_No[_index].agreementid;
    uint time = RoomAgreement_by_No[_AgreementNo].timestamp + RoomAgreement_by_No[_AgreementNo].lockInPeriod;
    require(now > time, "There is still time left for agreement to end!");
    _;
  }

  modifier rentTimeUp(uint _index) {
    uint time = Room_by_No[_index].timestamp + 30 days;
    require(now >= time, "There is still time left to pay rent!");
    _;
  }

  function addRoom(string memory _roomname, string memory _roomaddress, uint _rentcost, uint _securityDeposit) public {
    require(msg.sender != address(0));
    no_of_rooms ++;
    bool _vacant = true;
    Room_by_No[no_of_rooms] = Room(no_of_rooms, 0, _roomname, _roomaddress, _rentcost, _securityDeposit, 0, _vacant, msg.sender, address(0));
  }

  function signAgreement(uint _index) public payable notLandlord(_index) enoughAgreementFee(_index) onlyWhileVacant(_index){
    require(msg.sender != address(0));
    address payable _landlord = Room_by_No[_index].landlord;
    uint totalFee = Room_by_No[_index].rent_per_month + Room_by_No[_index].security_deposit;
    _landlord.transfer(totalFee);
    no_of_agreements++;
    Room_by_No[_index].currentTenant = msg.sender;
    Room_by_No[_index].vacant = false;
    Room_by_No[_index].timestamp = block.timestamp;
    Room_by_No[_index].agreementid = no_of_agreements;
    RoomAgreement_by_No[no_of_agreements] = RoomAgreement(_index, no_of_agreements, Room_by_No[_index].roomname, Room_by_No[_index].roomaddress, Room_by_No[_index].rent_per_month, Room_by_No[_index].security_deposit, 365 days, block.timestamp, msg.sender, _landlord);
    Rent_by_No[no_of_rent] = Rent(no_of_rent, _index, no_of_agreements, Room_by_No[_index].roomname, Room_by_No[_index].roomaddress, Room_by_No[_index].rent_per_month, now, msg.sender, _landlord);
  }

  function payRent(uint _index) public payable sameTenant(_index) rentTimeUp(_index) enoughRent(_index){
    require(msg.sender != address(0));
    address payable _landlord = Room_by_No[_index].landlord;
    uint _rent = Room_by_No[_index].rent_per_month;
    _landlord.transfer(_rent);
    Room_by_No[_index].currentTenant = msg.sender;
    Room_by_No[_index].vacant = false;
    no_of_rooms ++;
    Rent_by_No[no_of_rent] = Rent(no_of_rent, _index, Room_by_No[_index].agreementid, Room_by_No[_index].roomname, Room_by_No[_index].roomaddress, _rent, now, msg.sender, Room_by_No[_index].landlord);
  }

  function agreementCompleted(uint _index) public payable onlyLandlord(_index) agreementTimeUp(_index){
    require(msg.sender != address(0));
    require(Room_by_No[_index].vacant == false, "Room is currently occupied!");
    Room_by_No[_index].vacant = true;
    address payable _Tenant = Room_by_No[_index].currentTenant;
    uint _securityDeposit = Room_by_No[_index].security_deposit;
    _Tenant.transfer(_securityDeposit);
  }

  function agreementTerminated(uint _index) public onlyLandlord(_index) agreementTimeLeft(_index){
    require(msg.sender != address(0));
    Room_by_No[_index].vacant = true;
  }
}