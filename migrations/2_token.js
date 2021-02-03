const MyERC20 = artifacts.require("MyERC20");
const MyERC20_2 = artifacts.require("MyERC20_2");
const NewDollar = artifacts.require("NewDollar");

const migration = async (deployer, network, accounts) => {
    await Promise.all([
        deployToken(deployer, network),
    ]);
};

module.exports = migration;

async function deployToken(deployer, network) {
    await deployer.deploy(MyERC20);
    await deployer.deploy(MyERC20_2);
    await deployer.deploy(NewDollar,
            MyERC20.address,
            "New Dollar",
            "NUSD",
            18);
};