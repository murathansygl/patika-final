//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TodoImpact {

    address payable owner;
    uint public score;
    uint public goal;
    uint public balance;
    uint public toReceiveBack;
    uint public loss;
    uint public initialBalance;

    constructor(uint _goal) payable {
        require(_goal > 0, "Goal should be an integer larger than zero.");
        require(msg.value > 0);
        owner = payable(msg.sender);
        balance += msg.value;
        goal = _goal;
        initialBalance = balance;
    }

    function calculateLoss() external returns(uint loss) {
        loss = balance - toReceiveBack;
    }

    struct Todo {
        string text;
        bool completed;
        bool paid;
    }

    Todo[] public todos;

    modifier isOwner {
        require(msg.sender == owner);
        _;
    }

    event currentScore(uint score);
    event currentLoss(uint loss);
    
    function create(string calldata _text) public {
        todos.push(Todo(_text, false, false));
        emit currentScore(score);
    }

    function remove(uint _index) public {
        require(_index < todos.length);

        for (uint i = _index; i< todos.length-1; i++) {
            todos[i] = todos[i+1];
        }
        todos.pop();
        emit currentScore(score);
    }

    function get(uint _index) public view returns (string memory text, bool completed, bool paid) {
        Todo storage todo = todos[_index];
        return (todo.text, todo.completed, todo.paid);
    }
   
    function toggleCompleted(uint _index) public {
        Todo storage todo = todos[_index];
        todo.completed = !todo.completed;
        score += 2;
        if (todo.paid == false) {
            toReceiveBack += balance/todos.length;
        }
        
        todo.paid = true;
        emit currentLoss(loss);
    }

    function receivePrize() public payable isOwner {
        require(score >= goal, "Work harder to earn the prize");
        require(toReceiveBack <= balance, "Insufficient funds");
        balance -= toReceiveBack;
        payable(msg.sender).transfer(toReceiveBack);
        toReceiveBack = 0;
    }

    function emptyBalance() public payable isOwner {
        require(score >= goal, "Achieve your goal first");
        require(balance < initialBalance/todos.length);
        payable(msg.sender).transfer(balance);
        balance = 0;
    }

    function updateText(uint _index, string calldata _text) public {
        Todo storage todo = todos[_index];
        todo.text = _text;
    }
}
