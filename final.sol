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
    
    //The contract receives a goal input from the user. This will be an integer larger than zero.
    //Once the user's score exceeds the goal, the paid amount can be retrieved from the contract.

    constructor(uint _goal) payable {
        require(_goal > 0, "Goal should be an integer larger than zero.");
        require(msg.value > 0);
        owner = payable(msg.sender);
        balance += msg.value;
        goal = _goal;
        initialBalance = balance;
    }
    //Calculates the potential loss that the user might lose if they do not reach their goal.

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
    
    //Create new tasks for your todo list

    function create(string calldata _text) public {
        todos.push(Todo(_text, false, false));
        emit currentScore(score);
    }
    
    //Remove tasks from your todo list by giving the index of todo item. 
    //The rest will be shifted towards left so that there will be no empty item.

    function remove(uint _index) public {
        require(_index < todos.length);

        for (uint i = _index; i< todos.length-1; i++) {
            todos[i] = todos[i+1];
        }
        todos.pop();
        emit currentScore(score);
    }

    //Get a todo item by inputting its index
    
    function get(uint _index) public view returns (string memory text, bool completed, bool paid) {
        Todo storage todo = todos[_index];
        return (todo.text, todo.completed, todo.paid);
    }
    
    //Toggle todo item when completed. The user can toggle on and off multiple times, but the score
    //is received only once, and the money transaction occurs only once
    
    function toggleCompleted(uint _index) public {
        Todo storage todo = todos[_index];
        todo.completed = !todo.completed;
        
        if (todo.paid == false) {
            toReceiveBack += balance/todos.length;
            score += 2;
        }
        
        todo.paid = true;
        emit currentLoss(loss);
    }
    
    //Receive the amount back once reached the goal. Can only be called by the owner
    
    function receivePrize() public payable isOwner {
        require(score >= goal, "Work harder to earn the prize");
        require(toReceiveBack <= balance, "Insufficient funds");
        balance -= toReceiveBack;
        payable(msg.sender).transfer(toReceiveBack);
        toReceiveBack = 0;
    }
    
    //Prevents having left money in the contract. Can only be called by the owner
    
    function emptyBalance() public payable isOwner {
        require(score >= goal, "Achieve your goal first");
        require(balance < initialBalance/todos.length);
        payable(msg.sender).transfer(balance);
        balance = 0;
    }

    //Allows updating todo items
    
    function updateText(uint _index, string calldata _text) public {
        Todo storage todo = todos[_index];
        todo.text = _text;
    }
}
