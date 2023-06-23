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
        string sdgCategory;
        string image;
        string twitter;
        string youtube;
        string instagram;
        uint256 amountRecieved;
    }

    struct Project {
        uint256 projectId;
        uint256 explorerId;
        address payable owner;
        string explorerName;
        string cover;
        string title;
        Doners doners;
        string country;
        string community;
        uint256 target;
        string description;
        string sdgCategory;
        uint256 amountRecieved;
    }

    struct Doners {
        uint256 id;
        address _address;
        uint256 amount;
    }

    mapping(uint256 => Explorer) explorers;
    mapping(uint256 => Project) project;
    mapping(string => uint256) category;
    mapping(address => bool) public isRegistered;
    mapping(uint256 => mapping(uint256 => Doners)) public doners;

    //create functions
    function createEplorer(
        string memory _name,
        string memory _bio,
        string memory _country,
        string memory _sdgCategory,
        string memory _image,
        string memory _twitter,
        string memory _youtube,
        string memory _instagram
    ) public {
        explorersCount.increment();
        Explorer storage _explorer = explorers[explorersCount.current()];
        _explorer.id = explorersCount.current();
        _explorer.owner = payable(address(msg.sender));
        _explorer.dateJoined = block.timestamp;
        _explorer.name = _name;
        _explorer.bio = _bio;
        _explorer.country = _country;
        _explorer.sdgCategory = _sdgCategory;
        _explorer.image = _image;
        _explorer.twitter = _twitter;
        _explorer.youtube = _youtube;
        _explorer.instagram = _instagram;
        isRegistered[msg.sender] = true;
        explorers[explorersCount.current()] = _explorer;
    }

    function createProject(
        string memory _cover,
        string memory _title,
        string memory _country,
        string memory _sdgCategory,
        string memory _community,
        uint256 _target,
        string memory _description,
        uint256 _explorerId,
        string memory _explorerName
    ) public {
        projectCount.increment();
        Project storage _project = project[projectCount.current()];
        _project.projectId = projectCount.current();
        _project.explorerId = _explorerId;
        _project.explorerName = _explorerName;
        _project.cover = _cover;
        _project.title = _title;
        _project.country = _country;
        _project.sdgCategory = _sdgCategory;
        _project.community = _community;
        _project.target = _target;
        _project.description = _description;
        _project.owner = payable(address(msg.sender));
        project[projectCount.current()] = _project;
    }

    function addSponser(
        uint256 _id,
        uint256 _userId,
        string memory _categoryName
    ) public payable {
        require(_id > 0 && _id <= projectCount.current());
        Project storage _project = project[_id];
        Explorer storage _explorer = explorers[_userId];
        category[_categoryName] = category[_categoryName] + msg.value;
        address payable _owner = payable(address(_project.owner));
        _owner.transfer(msg.value);
        _project.amountRecieved = _project.amountRecieved + msg.value;
        _explorer.amountRecieved = _explorer.amountRecieved + msg.value;
        project[_id] = _project;
        explorers[_userId] = _explorer;
    }

    //get functions

    //get EthUsd
    function getEthUsd() public view returns (uint256) {
        (, int256 price, , , ) = eth_usd_price_feed.latestRoundData();
        return price.toUint256();
    }

    function getExplorer() public view returns (Explorer[] memory) {
        uint256 itemCount = explorersCount.current();
        uint256 currentIndex = 0;
        Explorer[] memory _explorer = new Explorer[](itemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            uint256 currentId = i + 1;
            Explorer storage currentItem = explorers[currentId];
            _explorer[currentIndex] = currentItem;
            currentIndex += 1;
        }
        return _explorer;
    }

    function getProject() public view returns (Project[] memory) {
        uint256 itemCount = projectCount.current();
        uint256 currentIndex = 0;
        Project[] memory _project = new Project[](itemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            uint256 currentId = i + 1;
            Project storage currentItem = project[currentId];
            _project[currentIndex] = currentItem;
            currentIndex += 1;
        }
        return _project;
    }

    function isRegisteredFunc() public view returns (bool) {
        if (isRegistered[msg.sender] == true) {
            return true;
        } else {
            return false;
        }
    }

    function getCategoryPrice(string memory _category)
        public
        view
        returns (uint256)
    {
        return category[_category];
    }
}