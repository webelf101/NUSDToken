// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract MyERC20 is IERC20 {

    mapping (uint256 => mapping (address => uint256)) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowances;

    mapping (address => bool) internal _minter;

    uint256 internal _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 internal _balanceKey;
    uint256 public updateTimestamp;
    uint256 public duration;

    address public owner;

    constructor () {

    }

    modifier onlyOwner{
        require(msg.sender == owner, "!owner");
        _;
    }

    modifier upgradeCheck() {
        uint256 passedTime = block.timestamp - updateTimestamp;
        if (passedTime / duration > 0) {
            updateTimestamp = block.timestamp - passedTime % duration;
            _upgrade();
        }
        _;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[_balanceKey][account];
    }

    function transfer(address recipient, uint256 amount) public virtual override upgradeCheck returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner_, address spender) public view virtual override returns (uint256) {
        return _allowances[owner_][spender];
    }

    function approve(address spender, uint256 amount) public virtual override upgradeCheck returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override upgradeCheck returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual upgradeCheck returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual upgradeCheck returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);
        return true;
    }

    function mint(address to_, uint256 amount_) external upgradeCheck {
        require(_minter[msg.sender], "!minter");
        _mint(to_, amount_);
    }

    function setMinter(address minter_) external onlyOwner upgradeCheck {
        _minter[minter_] = true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[_balanceKey][sender] -= amount;
        _balances[_balanceKey][recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[_balanceKey][account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[_balanceKey][account] -= amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner_, address spender, uint256 amount) internal virtual {
        require(owner_ != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    function _upgrade() internal {
        _balanceKey += 1;
        _totalSupply = 0;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}
