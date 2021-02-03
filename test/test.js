const MyERC20 = artifacts.require("MyERC20");
const MyERC20_2 = artifacts.require("MyERC20_2");
const NewDollar = artifacts.require("NewDollar");

contract("NewDollar", async accounts => {
    it("mint 1 token", async () => {
        await NewDollar.deployed();
        let newDollarToken = new web3.eth.Contract(MyERC20.abi, NewDollar.address);
        let one_token = web3.utils.toBN(10 ** 18);
        await newDollarToken.methods.setMinter(accounts[0]).send({from:accounts[0]});
        await newDollarToken.methods.mint(accounts[0], one_token.toString()).send({from:accounts[0]});
        let balance = await newDollarToken.methods.balanceOf(accounts[0]).call();
        assert.equal(balance.valueOf().toString(), one_token.toString());
    });

    it("upgrade smart contract and check balance reset", async () => {
        await NewDollar.deployed();
        let newDollarToken = new web3.eth.Contract(NewDollar.abi, NewDollar.address);
        await MyERC20_2.deployed();
        await newDollarToken.methods.upgradeImplementation(MyERC20_2.address).send({from:accounts[0]});
        newDollarToken = new web3.eth.Contract(MyERC20_2.abi, NewDollar.address);
        let balance = await newDollarToken.methods.balanceOf(accounts[0]).call();
        assert.equal(balance.valueOf(), 0);
    });
});