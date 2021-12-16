pragma solidity^ 0.4.17;

contract CampaignFactory {
    address[] public contracts;

    function deployCampaign(uint minimum) public {
        address newcampign = new KickStarter(minimum, msg.sender);
        contracts.push(newcampign);
    }

    function getaddress() public view returns (address[]){
        return contracts;
    }
}

contract KickStarter {
    struct Request{
        string description;
        uint value;
        address vendor;
        bool complete;
        mapping(address => bool) approvals;
        uint approve_cnt;
    }

    Request[] public requests;
    address public manager;
    mapping(address => bool) public contributers;
    uint public minimum_contri;
    uint public approvers_cnt;

    modifier restricted () {
        require(manager == msg.sender);
        _;
    }
    function KickStarter(uint minimum, address creator) public {
        manager = creator;
        minimum_contri = minimum;
    }

    function Enter() public payable {
        require(msg.value > minimum_contri);
        if(!contributers[msg.sender])
        {
            contributers[msg.sender] = true;
            approvers_cnt++;
        }
    }

    function createRequest(string description, uint value, address vendor) public restricted {
        Request memory newrequest = Request({
            description: description,
            value : value,
            vendor: vendor,
            complete: false,
            approve_cnt: 0
        });

        requests.push(newrequest);
    }

    function approveRequest(uint index) public {
        Request storage request = requests[index];
        require(contributers[msg.sender]);
        require(!request.approvals[msg.sender]);

        request.approve_cnt++;
        request.approvals[msg.sender] = true;
    }

    function Finalizerequest(uint index) public restricted {
        Request storage request = requests[index];
        require(!request.complete);
        require(request.approve_cnt > (approvers_cnt /2));
        request.complete = true;
        request.vendor.transfer(request.value);
    }

    function getSummary() public view returns(uint, uint, uint, uint, address) {
      return (
        minimum_contri,
        this.balance,
        requests.length,
        approvers_cnt,
        manager
      );
    }

    function getRequestsCount() public view returns(uint) {
      return requests.length;
    }
}
