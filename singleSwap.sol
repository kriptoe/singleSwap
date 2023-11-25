// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);
}

contract SingleSwap {
    address public constant routerAddress = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    ISwapRouter public immutable swapRouter = ISwapRouter(routerAddress);

     // address public constant WETH = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6; goerli
    address public WST = 0x03b54A6e9a984069379fae1a4fC4dBAE93B3bCCD;   // wrapped LIDO eth on polygon
    address public constant WETH = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619; // polygon
    // address public constant WETH = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;

    IERC20 public wethToken = IERC20(WETH);

    // For this example, we will set the pool fee to 0.3%.  3000
    // For this example, we will set the pool fee to 0.05%.  500    
    uint24 public  poolFee = 500;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    address private owner;

    constructor() {}


  // requires link in the contract to work
  // swaps link for WETH
    function swapExactInputSingle(uint256 amountIn)
        external
        returns (uint256 amountOut)
    {
        wethToken.approve(address(swapRouter), amountIn);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: WETH,
                tokenOut: WST,
                fee: poolFee,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        amountOut = swapRouter.exactInputSingle(params);
    }


    function changeTokenInAddress(address  _tokenAddress) external  onlyOwner{
          WST = _tokenAddress;
    }

    function swapExactOutputSingle(uint256 amountOut, uint256 amountInMaximum)
        external
        returns (uint256 amountIn)
    {
        wethToken.approve(address(swapRouter), amountInMaximum);

        ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter
            .ExactOutputSingleParams({
                tokenIn: WST,
                tokenOut: WETH,
                fee: poolFee,
                recipient: address(this),
                deadline: block.timestamp,
                amountOut: amountOut,
                amountInMaximum: amountInMaximum,
                sqrtPriceLimitX96: 0
            });

        amountIn = swapRouter.exactOutputSingle(params);

        if (amountIn < amountInMaximum) {
            wethToken.approve(address(swapRouter), 0);
            wethToken.transfer(address(this), amountInMaximum - amountIn);
        }
    }

    // Function to withdraw WETH from the contract, restricted to onlyOwner
    function withdrawWETH(uint256 amount) public {
        IERC20(WETH).transfer(msg.sender, amount);
    }

    // Function to withdraw WST from the contract, restricted to onlyOwner
    function withdrawWST(uint256 amount) public {
        IERC20(WST).transfer(msg.sender, amount);
    }

        // Function to withdraw WETH or WST from the contract
    function changePoolFee(uint24 amount) external  onlyOwner{
         poolFee = amount;
    }

}
