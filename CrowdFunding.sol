//Funding project details
pragma solidity ^0.4.26;
contract CrowdfundinfProject{
    struct FundingProject {
        string name;
        string email;
        string website;
        uint minimumfunds;
        uint amountraised;
        address owner;
        string status;
    }
    
    //Funder who funds project.
    struct Funder {
        string name;
        address fundedby;
        uint amount;
    }

    //Multiple funders can fund project
    Funder[] public funders;
    FundingProject public fundingproject;
    
    //modifier
    modifier onlyOwner() {
        require(msg.sender == fundingproject.owner,"Only owner can call this function.");
        _;
    }
   
    function CrowdFunding(string _name, string _email, string _website, uint _minimumfunds, address _owner) public 
    {
         //convert to ether
        uint minimumfunds = _minimumfunds * 1 ether;
        uint amountraised = 0;
        fundingproject = FundingProject(_name,_email,_website,minimumfunds,amountraised,_owner,"Funding Started");
    }
    function fundProject( string name) public payable {
        if (keccak256("Funding Stopped")== keccak256(fundingproject.status)) revert();
        if (keccak256("Funding Completed")== keccak256(fundingproject.status)) revert();
        funders.push(Funder({
        	name: name,
        	fundedby: msg.sender,
        	amount: msg.value}) 
        );
        fundingproject.amountraised = fundingproject.amountraised + msg.value ;
                        
        if (fundingproject.amountraised >= fundingproject.minimumfunds) {
        	if(!fundingproject.owner.send(fundingproject.amountraised )) revert();				 
                fundingproject.status = "Funding Completed";
        	} 
        	else {		   			
                fundingproject.status = "In Progress";
        	}
    }
    function stopFundRaising() public payable onlyOwner {
    	 if (keccak256(fundingproject.status)== keccak256("Funding Completed")) revert();
    	    fundingproject.status = "Funding Stopped";
    	 //return money to all funders
    	 for (uint p = 0; p < funders.length; p++) {
    	 	if(!funders[p].fundedby.send(funders[p].amount)) throw;
    	 }
    	 fundingproject.amountraised = 0;
    }
    function getProjectStatus() public constant	returns(string) {
    		return (fundingproject.status);
    }
}