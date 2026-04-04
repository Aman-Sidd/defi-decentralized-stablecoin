// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "test/MockV3Aggregator.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract HelperConfig {
    struct NetworkConfig {
        address wethUsdPriceFeed;
        address wbtcUsdPriceFeed;
        address weth;
        address wbtc;
        uint256 deployerKey;
    }

    uint8 public constant DECIMALS = 8;
    int256 public constant ETH_USD_PRICE = 2000e8;
    int256 public constant BTC_USD_PRICE = 1000e8;
    uint256 public constant DEFAULT_ANVIL_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    NetworkConfig public activeNetworkConfig;

    constructor() {
        if(block.chainid == 11155111){
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public view returns (NetworkConfig memory) {
        return
            NetworkConfig({
                wethUsdPriceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419,
                wbtcUsdPriceFeed: 0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c,
                weth: 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14,
                wbtc: 0x29f2D40B0605204364af54EC677bD022dA425d03,
                deployerKey: vm.envUint("PRIVATE_KEY")
            });
    }

    function getOrCreateAnvilEthConfig()
        public
        view
        returns (NetworkConfig memory)
    {
        if (activeNetworkConfig.wethUsdPriceFeed != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator ethUsdPriceFeed = new MockV3Aggregator(
            DECIMALS,
            ETH_USD_PRICE
        );

        ERC20Mock wethMock = new ERC20Mock("WETH", "WETH", msg.sender, 1000e8);

        MockV3Aggregator btcUsdPriceFeed = new MockV3Aggregator(
            DECIMALS,
            BTC_USD_PRICE
        );

        ERC20Mock wbtcMock = new ERC20Mock("WBTC", "WBTC", msg.sender, 1000e8);

        return NetworkConfig({
            wethUsdPriceFeed: address(ethUsdPriceFeed),
            wbtcUsdPriceFeed: address(btcUsdPriceFeed),
            weth: address(wethMock),
            wbtc: address(wbtcMock),
            deployerKey: DEFAULT_ANVIL_KEY
        })
    }
}
