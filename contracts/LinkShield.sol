// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

contract linkShield {
    struct Link {
        string url;
        address owner;
        uint256 fee;
        uint256 createdAt;
        uint256 buyCounter;
    }
    uint256 public commission = 1;
    address public admin = msg.sender;

    mapping(string => Link) private links;
    mapping(string => mapping(address => bool)) public hasAccess;

    function editCommission(uint256 newCommission) public {
        require(msg.sender == admin, "Only admin can edit commission");
        commission = newCommission;
    }
    function removeLink(string calldata linkId) public {
        require(msg.sender == admin, "Only admin can delete links");
        delete  links[linkId];

    }

    function addLink(
        string calldata url,
        string calldata linkId,
        uint256 fee
    ) public {
        Link storage link = links[linkId];
        require(
            link.owner == address(0) || link.owner == msg.sender,
            "This linkId alread has an owner"
        );
        require(fee == 0 || fee > commission, "Fee too low");
        link.url = url;
        link.fee = fee;
        link.createdAt = block.timestamp;
        link.owner = msg.sender;
        link.buyCounter = 0;
        links[linkId] = link;
        hasAccess[linkId][msg.sender] = true;
    }

    function buyAccess(string calldata linkId) public payable {
        Link storage link = links[linkId];
        require(link.owner != address(0), "Link not Found");
        require(
            hasAccess[linkId][msg.sender] == false,
            "You alread have access"
        );
        require(msg.value >= link.fee, "Insufficient payment");
        hasAccess[linkId][msg.sender] = true;
        payable(link.owner).transfer(msg.value - commission);
        link.buyCounter += 1;
    }

    function getLink(string calldata linkId)
        public
        view
        returns (
            string memory,
            uint256,
            uint256,
            uint256
        )
    {
        Link storage link = links[linkId];
        require(link.owner != address(0), "Link not Found");

        if (link.fee == 0 || hasAccess[linkId][msg.sender] == true) {
            return (link.url, link.fee, link.createdAt, link.buyCounter);
        } else {
            return (
                "You need to buy access",
                link.fee,
                link.createdAt,
                link.buyCounter
            );
        }
    }
}
