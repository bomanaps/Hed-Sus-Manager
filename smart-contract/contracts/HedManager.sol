// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract HedManager {
    using SafeCast for int256;
    using SafeMath for uint256;

    AggregatorV3Interface internal eth_usd_price_feed;

    using Counters for Counters.Counter;
    Counters.Counter private explorersCount;
    Counters.Counter private donersCount;
    Counters.Counter private projectCount;

    constructor() {
        eth_usd_price_feed = AggregatorV3Interface(
            0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada
        );
    }

    struct Explorer {
        uint256 id;
        address payable owner;
        uint256 dateJoined;
        string name;
        string bio;
        string country;
        string avatar;
        string twitter;
        string github;
        uint256 amountReceived; // Updated field name
    }

    struct Doners {
        uint256 id;
        address _address;
        uint256 amount;
    }

    struct Project {
        uint256 projectId;
        uint256 explorerId;
        address payable owner;
        string explorerName;
        string image;
        string title;
        Doners doners;
        string github_link;
        string demo;
        string website;
        uint256 target_amount;
        string description;
        string Category;
        uint256 amountReceived; // Updated field name
    }

    mapping(uint256 => Explorer) explorers;
    mapping(uint256 => Project) project;
    mapping(string => uint256) category;
    mapping(address => bool) public isRegistered;
    mapping(uint256 => mapping(uint256 => Doners)) public doners;

    // Create functions
    function createExplorer(
        string memory _name,
        string memory _bio,
        string memory _country,
        string memory _avatar,
        string memory _twitter,
        string memory _github
    ) public {
        explorersCount.increment();
        Explorer storage _explorer = explorers[explorersCount.current()];
        _explorer.id = explorersCount.current();
        _explorer.owner = payable(address(msg.sender));
        _explorer.dateJoined = block.timestamp;
        _explorer.name = _name;
        _explorer.bio = _bio;
        _explorer.country = _country;
        _explorer.avatar = _avatar;
        _explorer.twitter = _twitter;
        _explorer.github = _github;
        isRegistered[msg.sender] = true;
        explorers[explorersCount.current()] = _explorer;
    }

    function createProject(
        string memory _image,
        string memory _title,
        string memory _github_link,
        string memory _demo,
        string memory _website,
        uint256 _target_amount,
        string memory _description,
        uint256 _explorerId,
        string memory _explorerName
    ) public {
        projectCount.increment();
        Project storage _project = project[projectCount.current()];
        _project.projectId = projectCount.current();
        _project.explorerId = _explorerId;
        _project.explorerName = _explorerName;
        _project.image = _image;
        _project.title = _title;
        _project.github_link = _github_link;
        _project.demo = _demo;
        _project.website = _website;
        _project.target_amount = _target_amount;
        _project.description = _description;
        _project.owner = payable(address(msg.sender));
        project[projectCount.current()] = _project;
    }

    function addSponsor(
        uint256 _id,
        uint256 _userId,
        string memory _categoryName
    ) public payable {
        require(_id > 0 && _id <= projectCount.current());
        Project storage _project = project[_id];
        Explorer storage _explorer = explorers[_userId];
        category[_categoryName] = category[_categoryName].add(msg.value);
        address payable _owner = payable(address(_project.owner));
        _owner.transfer(msg.value);
        _project.amountReceived = _project.amountReceived.add(msg.value);
        _explorer.amountReceived = _explorer.amountReceived.add(msg.value);
        project[_id] = _project;
        explorers[_userId] = _explorer;
    }

    // Get functions

    // Get ETH/USD price
    function getEthUsd() public view returns (uint256) {
        (, int256 price, , , ) = eth_usd_price_feed.latestRoundData();
        return price.toUint256();
    }

    function getExplorers() public view returns (Explorer[] memory) {
        uint256 itemCount = explorersCount.current();
        Explorer[] memory _explorers = new Explorer[](itemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            uint256 currentId = i + 1;
            Explorer storage currentItem = explorers[currentId];
            _explorers[i] = currentItem;
        }
        return _explorers;
    }

    function getProjects() public view returns (Project[] memory) {
        uint256 itemCount = projectCount.current();
        Project[] memory _projects = new Project[](itemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            uint256 currentId = i + 1;
            Project storage currentItem = project[currentId];
            _projects[i] = currentItem;
        }
        return _projects;
    }

    function isRegisteredFunc() public view returns (bool) {
        return isRegistered[msg.sender];
    }

    function getCategoryPrice(string memory _category)
        public
        view
        returns (uint256)
    {
        return category[_category];
    }
}
