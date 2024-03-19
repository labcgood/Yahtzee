//
//  ViewController.swift
//  Yahtzee
//
//  Created by Labe on 2024/3/8.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    //玩家名稱TextField
    @IBOutlet weak var playerOneTextField: UITextField!
    @IBOutlet weak var playerTwoTextField: UITextField!
    //回合數Label
    @IBOutlet weak var roundLabel: UILabel!
    //欄位Label(上、下)
    @IBOutlet weak var dicePointLabel: UILabel!
    @IBOutlet weak var assembleLabel: UILabel!
    //下方資訊欄Label
    @IBOutlet weak var infoLabel: UILabel!
    //骰子Button
    @IBOutlet weak var firstDiceButton: UIButton!
    @IBOutlet weak var secondDiceButton: UIButton!
    @IBOutlet weak var thirdDiceButton: UIButton!
    @IBOutlet weak var fourthDiceButton: UIButton!
    @IBOutlet weak var fifthDiceButton: UIButton!
    //骰子Button的Array
    @IBOutlet var diceButtons: [UIButton]!
    //骰骰子Button
    @IBOutlet weak var rollDiceButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    //玩家1的點數Button Array
    @IBOutlet var playerOnePointsButtons: [UIButton]!
    @IBOutlet var playerTwoPointsButtons: [UIButton]!
    //玩家總積分Label
    @IBOutlet weak var totalPointsLabel: UILabel!
    @IBOutlet weak var playerOneTotalPointsLabel: UILabel!
    @IBOutlet weak var playerTwoTotalPointsLabel: UILabel!
    
    
    //骰子的Array、回合數、骰骰子數、目前玩家、當前骰子的Array、玩家總分數
    var dices:[Dice] = []
    var numOfRound = 1
    var rollDiceCount = 0
    var currentPlayerIndex = 0
    var currentDicesArray:[Dice] = []
    var playerOneTotalPoints = 0
    var playerTwoTotalPoints = 0
    var playerOneName = ""
    var playerTwoName = ""
    

    //骰子顏色
    let originalDiceColor = CGColor(red: 238/255, green: 240/255, blue: 229/255, alpha: 1)
    let changeDiceColor = CGColor(red: 164/255, green: 206/255, blue: 149/255, alpha: 1)
    
    //轉換骰子顏色
    func switchButtonColor(button: UIButton) {
        if button.layer.backgroundColor == originalDiceColor {
            button.layer.backgroundColor = changeDiceColor
            button.layer.cornerRadius = 15
        } else {
            button.layer.backgroundColor = originalDiceColor
            button.layer.cornerRadius = 15
        }
    }
    
    //選取的Button不能再使用、改變文字顏色、調整透明度、存取回合數
    func closeButton(button: UIButton) {
        button.isEnabled = false
        button.setTitleColor(UIColor(red: 22/225, green: 48/225, blue: 32/225, alpha: 1), for: .normal)
        button.alpha = 0.5
        switchPlayer(button: playerOnePointsButtons)
        switchPlayer(button: playerTwoPointsButtons)
        
        //回合數，輪到玩家2時，回合數等於12就停止增加
        if currentPlayerIndex == 0 {
            currentPlayerIndex = 1
            infoLabel.text = playerTwoName + " 遊玩"
            for i in 0...11 {
                if playerTwoPointsButtons[i].alpha == 1 {
                    playerTwoPointsButtons[i].isEnabled = true
                }
                if playerOnePointsButtons[i].alpha == 1 {
                    playerOnePointsButtons[i].isEnabled = false
                }
            }
        } else if currentPlayerIndex == 1 && numOfRound != 12 {
            currentPlayerIndex = 0
            infoLabel.text = playerOneName + " 遊玩"
            numOfRound += 1
            for i in 0...11 {
                if playerOnePointsButtons[i].alpha == 1 {
                    playerOnePointsButtons[i].isEnabled = true
                }
                if playerTwoPointsButtons[i].alpha == 1 {
                    playerTwoPointsButtons[i].isEnabled = false
                }
            }
        }
        roundLabel.text = "\(numOfRound)/12"
        
        //結算遊戲結果(如果玩家所有Button都不能選取就結算遊戲)
        if currentPlayerIndex == 1 && numOfRound == 12 {
            var buttonCounter = 0
            for i in 0...11 {
                if playerTwoPointsButtons[i].isEnabled == false {
                    buttonCounter += 1
                }
            }
            if buttonCounter == 12 {
                //關掉骰骰子的功能、隱藏骰子
                rollDiceButton.isEnabled = false
                for i in 0...4 {
                    diceButtons[i].isHidden = true
                }
                
                //存取玩家1、玩家2的點數並比較大小得出結果
                let point1 = gameSettlement(buttons: playerOnePointsButtons)
                let point2 = gameSettlement(buttons: playerTwoPointsButtons)
                print(point1)
                print(point2)
                if point1 > point2 {
                    playerOneTotalPointsLabel.text = "♛\n" + playerOneName + "\n\(point1)"
                    playerTwoTotalPointsLabel.text = "\n" + playerTwoName + "\n\(point2)"
                    infoLabel.text = playerOneName + " 贏了！"
                    showResult(show: false)
                } else if point1 < point2 {
                    playerOneTotalPointsLabel.text = "\n" + playerOneName + "\n\(point1)"
                    playerTwoTotalPointsLabel.text = "♛\n" + playerTwoName + "\n\(point2)"
                    infoLabel.text = playerTwoName + " 贏了！"
                    showResult(show: false)
                } else if point1 == point2 {
                    playerOneTotalPointsLabel.text = playerOneName + "\n\(point1)"
                    playerTwoTotalPointsLabel.text = playerTwoName + "\n\(point2)"
                    infoLabel.text = "平手！"
                    showResult(show: false)
                }
            }
        }
        
    }
    
    //計算遊戲總得分數
    func gameSettlement(buttons: [UIButton]) -> Int {
        var point = 0
        for i in 0...5 {
            point += Int((buttons[i].titleLabel?.text)!)!
        }
        if point >= 63 {
            point += 35
        }
        for i in 6...11 {
            point += Int((buttons[i].titleLabel?.text)!)!
        }
        return point
    }
    
    //判斷得分
    func judgeScore(playerButtons: [UIButton], currentDices: [Dice]) {
        //重置目前得到的分數
        var playerPointsArray:[Int] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        for i in 0...11 {
            if playerButtons[i].isEnabled == true  {
                playerButtons[i].setTitle("\(playerPointsArray[i])", for: .normal)
            }
        }
        
        //判斷分數
        for i in 0...4 {
            //1-6點
            if currentDices[i].point == 1 && playerButtons[0].isEnabled == true {
                playerPointsArray[0] += 1
                playerButtons[0].setTitle("\(playerPointsArray[0])", for: .normal)
            } else if currentDices[i].point == 2 && playerButtons[1].isEnabled == true {
                playerPointsArray[1] += 2
                playerButtons[1].setTitle("\(playerPointsArray[1])", for: .normal)
            } else if currentDices[i].point == 3 && playerButtons[2].isEnabled == true {
                playerPointsArray[2] += 3
                playerButtons[2].setTitle("\(playerPointsArray[2])", for: .normal)
            } else if currentDices[i].point == 4 && playerButtons[3].isEnabled == true {
                playerPointsArray[3] += 4
                playerButtons[3].setTitle("\(playerPointsArray[3])", for: .normal)
            } else if currentDices[i].point == 5 && playerButtons[4].isEnabled == true {
                playerPointsArray[4] += 5
                playerButtons[4].setTitle("\(playerPointsArray[4])", for: .normal)
            } else if currentDices[i].point == 6 && playerButtons[5].isEnabled == true {
                playerPointsArray[5] += 6
                playerButtons[5].setTitle("\(playerPointsArray[5])", for: .normal)
            }
            
            //全選
            playerPointsArray[6] += currentDices[i].point
            if playerButtons[6].isEnabled == true {
                playerButtons[6].setTitle("\(playerPointsArray[6])", for: .normal)
            }
        }
        
        var judgeArray = [0, 0, 0, 0, 0, 0]
        var twoPointsSame = false
        var threePointsSame = false
        var consecutiveCount = 0
        var smallStraight = false
        var largeStraight = false
        
        //儲存judgeArray的值
        for i in currentDices {
            judgeArray[i.point-1] += 1
        }
            
        for i in 0...5 {
            //判斷快艇、四骰同花、存取判斷葫蘆用的Bool
            if judgeArray[i] == 5 && playerButtons[11].isEnabled == true {
                //四骰
                var totalPoint = 0
                for i in 0...4 {
                    totalPoint += currentDices[i].point
                }
                playerButtons[7].setTitle("\(totalPoint)", for: .normal)
                //快艇
                playerButtons[11].setTitle("50", for: .normal)
            } else if judgeArray[i] == 4 && playerButtons[7].isEnabled == true {
                //四骰
                var totalPoint = 0
                for i in 0...4 {
                    totalPoint += currentDices[i].point
                }
                playerButtons[7].setTitle("\(totalPoint)", for: .normal)
            } else if judgeArray[i] == 3 {
                threePointsSame = true
            } else if judgeArray[i] == 2 {
                twoPointsSame = true
            }
            
            //判斷順子用的變數
            if judgeArray[i] >= 1 {
                consecutiveCount += 1
            } else {
                consecutiveCount = 0
            }
            
            if consecutiveCount == 4 {
                smallStraight = true
            } else if consecutiveCount == 5 {
                smallStraight = true
                largeStraight = true
            }
            print(consecutiveCount)
        }
        
        //判斷葫蘆、大、小順
        if twoPointsSame == true && threePointsSame == true  && playerButtons[8].isEnabled == true{
            playerButtons[8].setTitle("25", for: .normal)
        }
        if smallStraight == true && playerButtons[9].isEnabled == true {
            playerButtons[9].setTitle("30", for: .normal)
        }
        if largeStraight == true && playerButtons[10].isEnabled == true {
            playerButtons[10].setTitle("40", for: .normal)
        }
    }
    
    //更換玩家
    func switchPlayer(button: [UIButton]) {
        //重置骰子
        rollDiceButton.isEnabled = true
        rollDiceCount = 0
        for i in 0...4 {
            let image = UIImage(named: "1")
            diceButtons[i].setImage(image, for: .normal)
            diceButtons[i].layer.backgroundColor = originalDiceColor
        }
        //隱藏沒用到的Button文字
        for i in 0...11 {
            if button[i].alpha != 0.5 {
                button[i].setTitle("", for: .normal)
            }
        }
        
    }
    
    //顯示總積分
    func showResult(show: Bool) {
        totalPointsLabel.isHidden = show
        playerOneTotalPointsLabel.isHidden = show
        playerTwoTotalPointsLabel.isHidden = show
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        playerOneTextField.delegate = self
        playerTwoTextField.delegate = self
        playerOneTextField.layer.cornerRadius = 22
        playerTwoTextField.layer.cornerRadius = 22
        playerOneTextField.clipsToBounds = true
        playerTwoTextField.clipsToBounds = true
        
        //玩家名稱
        if playerOneTextField.text == nil || playerOneTextField.text == "" {
            playerOneName = playerOneTextField.placeholder!
        }
        if playerTwoTextField.text == nil || playerTwoTextField.text == "" {
            playerTwoName = playerTwoTextField.placeholder!
        }
        
        //預設遊戲資訊
        infoLabel.text = playerOneName + " 遊玩"
        
        //建立骰子並加入dices Array
        for i in 1...6 {
            let dice = Dice(point: i)
            dices.append(dice)
        }
        
        //建立目前骰子的Array
        for _ in 1...5 {
            currentDicesArray.append(dices[0])
        }
        
        
        //設定Label顏色、圓角
        dicePointLabel.layer.backgroundColor = CGColor(red: 252/255, green: 220/255, blue: 42/255, alpha: 0.6)
        dicePointLabel.layer.cornerRadius = 15
        assembleLabel.layer.backgroundColor = CGColor(red: 252/255, green: 220/255, blue: 42/255, alpha: 0.6)
        assembleLabel.layer.cornerRadius = 15
        infoLabel.layer.backgroundColor = CGColor(red: 252/255, green: 220/255, blue: 42/255, alpha: 0.6)
        infoLabel.layer.cornerRadius = 15
        
        //設定骰子的顏色
        for i in 0...4 {
            let image = UIImage(named: "1")
            diceButtons[i].setImage(image, for: .normal)
            diceButtons[i].layer.backgroundColor = originalDiceColor
            diceButtons[i].layer.cornerRadius = 15
        }
        
        //設定button
        for i in 0...11 {
            //玩家1
            playerOnePointsButtons[i].titleLabel?.font = UIFont(name: "NaikaiFont-ExtraLight", size: 20)
            playerOnePointsButtons[i].setTitleColor(UIColor(red: 1, green: 0, blue: 77/255, alpha: 1), for: .normal)
            playerOnePointsButtons[i].layer.cornerRadius = 10
            //玩家2
            playerTwoPointsButtons[i].titleLabel?.font = UIFont(name: "NaikaiFont-ExtraLight", size: 20)
            playerTwoPointsButtons[i].setTitleColor(UIColor(red: 1, green: 0, blue: 77/255, alpha: 1), for: .normal)
            playerTwoPointsButtons[i].layer.cornerRadius = 10
            playerTwoPointsButtons[i].isEnabled = false
        }
        
    }
    
    //收回鍵盤
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
                playerOneTextField.resignFirstResponder()
                playerTwoTextField.resignFirstResponder()
                return true
            }

    //輸入玩家名稱
    @IBAction func setPlayerOneNameTextFeild(_ sender: Any) {
        playerOneName = playerOneTextField.text!
        if currentPlayerIndex == 0 {
            infoLabel.text = playerOneName + " 遊玩"
        }
        print(playerOneName)
    }
    
    @IBAction func setPlayerTwoNameTextFeild(_ sender: Any) {
        playerTwoName = playerTwoTextField.text!
        if currentPlayerIndex == 1 {
            infoLabel.text = playerTwoName + " 遊玩"
        }
        print(playerTwoName)
    }
    
    //丟骰子
    @IBAction func rollDiceButton(_ sender: Any) {
        //如果骰子顏色沒有變(沒有被選取)，就再繼續骰
        //把當前的骰子存起來，被骰掉的會被新新骰出來的骰子取代
        for i in 0...4 {
            if diceButtons[i].layer.backgroundColor == originalDiceColor {
                let currentDice = dices.randomElement()!
                let image = UIImage(named: "\(currentDice.point)")
                currentDicesArray[i] = currentDice
                diceButtons[i].setImage(image, for: .normal)
            }
        }
        
        //計算骰骰子的數量，如果骰完3次就不能再骰
        print(currentDicesArray)
        rollDiceCount += 1
        if rollDiceCount >= 3 {
            rollDiceButton.isEnabled = false
        }
        
        //以currentPlayerIndex判斷當前玩家，並帶入相對玩家顯示分數的[Button]進行遊戲得分判斷
        if currentPlayerIndex == 0 {
            judgeScore(playerButtons: playerOnePointsButtons, currentDices: currentDicesArray)
        } else if currentPlayerIndex == 1 {
            judgeScore(playerButtons: playerTwoPointsButtons, currentDices: currentDicesArray)
        }
        
        
    }

    //點擊骰子變換顏色
    @IBAction func firstDiceButton(_ sender: Any) {
        switchButtonColor(button: firstDiceButton)
    }
    
    @IBAction func secondDiceButton(_ sender: Any) {
        switchButtonColor(button: secondDiceButton)
    }
    
    @IBAction func thirdDiceButton(_ sender: Any) {
        switchButtonColor(button: thirdDiceButton)
    }
    
    @IBAction func fourthDiceButton(_ sender: Any) {
        switchButtonColor(button: fourthDiceButton)
    }
    
    @IBAction func fifthDiceButton(_ sender: Any) {
        switchButtonColor(button: fifthDiceButton)
    }
    
    //選取分數的Button
    //玩家1
    @IBAction func player1Button1(_ sender: Any) {
        closeButton(button: playerOnePointsButtons[0])
    }
    
    @IBAction func player1Button2(_ sender: Any) {
        closeButton(button: playerOnePointsButtons[1])
    }
    
    @IBAction func player1Button3(_ sender: Any) {
        closeButton(button: playerOnePointsButtons[2])
    }
    
    @IBAction func player1Button4(_ sender: Any) {
        closeButton(button: playerOnePointsButtons[3])
    }
    
    @IBAction func player1Button5(_ sender: Any) {
        closeButton(button: playerOnePointsButtons[4])
    }
    
    @IBAction func player1Button6(_ sender: Any) {
        closeButton(button: playerOnePointsButtons[5])
    }
    
    @IBAction func player1Button7(_ sender: Any) {
        closeButton(button: playerOnePointsButtons[6])
    }
    
    @IBAction func player1Button8(_ sender: Any) {
        closeButton(button: playerOnePointsButtons[7])
    }
    
    @IBAction func player1Button9(_ sender: Any) {
        closeButton(button: playerOnePointsButtons[8])
    }
    
    @IBAction func player1Button10(_ sender: Any) {
        closeButton(button: playerOnePointsButtons[9])
    }
    
    @IBAction func player1Button11(_ sender: Any) {
        closeButton(button: playerOnePointsButtons[10])
    }
    
    @IBAction func player1Button12(_ sender: Any) {
        closeButton(button: playerOnePointsButtons[11])
    }
    //玩家2
    @IBAction func player2Button1(_ sender: Any) {
        closeButton(button: playerTwoPointsButtons[0])
    }
    
    @IBAction func player2Button2(_ sender: Any) {
        closeButton(button: playerTwoPointsButtons[1])
    }
    
    @IBAction func player2Button3(_ sender: Any) {
        closeButton(button: playerTwoPointsButtons[2])
    }
    
    @IBAction func player2Button4(_ sender: Any) {
        closeButton(button: playerTwoPointsButtons[3])
    }
    
    @IBAction func player2Button5(_ sender: Any) {
        closeButton(button: playerTwoPointsButtons[4])
    }
    
    @IBAction func player2Button6(_ sender: Any) {
        closeButton(button: playerTwoPointsButtons[5])
    }
    
    @IBAction func player2Button7(_ sender: Any) {
        closeButton(button: playerTwoPointsButtons[6])
    }
    
    @IBAction func player2Button8(_ sender: Any) {
        closeButton(button: playerTwoPointsButtons[7])
    }
    
    @IBAction func player2Button9(_ sender: Any) {
        closeButton(button: playerTwoPointsButtons[8])
    }
    
    @IBAction func player2Button10(_ sender: Any) {
        closeButton(button: playerTwoPointsButtons[9])
    }
    
    @IBAction func player2Button11(_ sender: Any) {
        closeButton(button: playerTwoPointsButtons[10])
    }
    
    @IBAction func player2Button12(_ sender: Any) {
        closeButton(button: playerTwoPointsButtons[11])
    }
    
    //重新開始(重置)
    @IBAction func restartButton(_ sender: Any) {
        //回合數
        numOfRound = 1
        roundLabel.text = "\(numOfRound)/12"
        
        //骰骰子數、目前玩家、玩家點數
        rollDiceCount = 0
        currentPlayerIndex = 0
        playerOneTotalPoints = 0
        playerTwoTotalPoints = 0
        
        for i in 0...11 {
            //玩家1分數Button
            playerOnePointsButtons[i].setTitle("", for: .normal)
            playerOnePointsButtons[i].setTitleColor(UIColor(red: 1, green: 0, blue: 77/255, alpha: 1), for: .normal)
            playerOnePointsButtons[i].alpha = 1
            playerOnePointsButtons[i].isEnabled = true
            //玩家2分數Button重置
            playerTwoPointsButtons[i].setTitle("", for: .normal)
            playerTwoPointsButtons[i].setTitleColor(UIColor(red: 1, green: 0, blue: 77/255, alpha: 1), for: .normal)
            playerTwoPointsButtons[i].alpha = 1
        }
        
        //顯示骰子、重置骰子圖片、開啟骰骰子Button
        for i in 0...4 {
            diceButtons[i].isHidden = false
            let image = UIImage(named: "1")
            diceButtons[i].setImage(image, for: .normal)
        }
        rollDiceButton.isEnabled = true
        
        //隱藏總積分
        showResult(show: true)
        
        //遊戲資訊
        infoLabel.text = playerOneName + " 遊玩"
    }
}
