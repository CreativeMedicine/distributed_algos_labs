var node = artifacts.require("./lcr_node.sol");

module.exports = function(deployer) {
  deployer.deploy(node, 8);
  deployer.deploy(node, 10);
  deployer.deploy(node, 9);
};
