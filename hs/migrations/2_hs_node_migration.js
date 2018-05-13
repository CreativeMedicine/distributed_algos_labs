var Migrations = artifacts.require("./hs_node.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
};
