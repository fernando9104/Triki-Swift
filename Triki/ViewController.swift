//
//  ViewController.swift
//  Triki
//
//  Created by Developer02 on 18/10/18.
//  Copyright © 2018 Developer02. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var titleLabel1: UILabel!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var avatarGame: UIImageView!
    @IBOutlet weak var gameModePicker: UIPickerView!
    @IBOutlet weak var uiBox1: UIButton!
    @IBOutlet weak var uiBox2: UIButton!
    @IBOutlet weak var uiBox3: UIButton!
    @IBOutlet weak var uiBox4: UIButton!
    @IBOutlet weak var uiBox5: UIButton!
    @IBOutlet weak var uiBox6: UIButton!
    @IBOutlet weak var uiBox7: UIButton!
    @IBOutlet weak var uiBox8: UIButton!
    @IBOutlet weak var uiBox9: UIButton!
    
    var playerOneBoard:[Int:Bool]?
    var playerTwoBoard:[Int:Bool]?
    var mainControl:MainControl?
    var player1:Player?
    var player2:Player?
    var playerCPU:CPUPlayer?
    
    // Constructor
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prepara el juego
        prepareGame()
        
    }// fin de viewDidLoad
    
    // Funcion que se encarga de a listar las configuraciones del juego
    private func prepareGame(){
        mainControl = MainControl( context: self )
        player1     = Player(name: "Luis", typeBox: "Nought")
    }
    
    // Funcion que escucha el evento del boton Play
    @IBAction func mainControlButton(_ sender: UIButton) {
        
        if( mainControl != nil ){
            
            // Indentifica el boton
            switch( sender.tag ){
            case 0: // Restart
                mainControl?.restartGame()
                break;
            case 1: // Play
                mainControl?.startGame()
                break;
            default:
                break;
            }// Fin del switch
        }
        
    }// Fin de mainControlButton
    
    // Funcion que escucha el evento de los botones fichas de juego
    @IBAction func gameTokensButton(_ sender: UIButton) {
        
        if( mainControl != nil ){
            
            if( mainControl!.gameIsStarted() ){
                
                // Indentifica el jugador
                switch( mainControl?.getCurrentPlayer() ){
                    case 1: // Player 1
                        if( player1?.getPlayerBoard()[sender.tag] == false ){
                            mainControl?.currentPlayer(player: 1)
                            mainControl?.setMovementBoard(movedPlayed: sender)
                            mainControl?.checkPlayerMovement(movedPlayed: sender)
                        }
                        break;
                    case 2: // Player 2
                        if( player2?.getPlayerBoard()[sender.tag] == false ){
                            mainControl?.currentPlayer(player: 2)
                            mainControl?.setMovementBoard(movedPlayed: sender)
                            mainControl?.checkPlayerMovement(movedPlayed: sender)
                        }
                        break;
                    default:
                        break;
                }// Fin del switch
            }
        }
        
    }// Fin de gameTokensButton
    
    // Configura el Picker View Data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (mainControl?.getGameMode().count)!
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (mainControl?.getGameMode()[row])!
    }
    
    // Evento del Picker View Data
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        mainControl?.setModeSelected(selected:row)
    }

    // ******************** CLASES ********************** //
    
    /* **** Clase Control Principal **** */
    class MainControl {
        
        private var isStarted:Bool = false
        private var currPlayer:Int?
        private let parentCtxt:ViewController?
        private var generalPieceMoved:[UIButton]?
        private var winningMovements:[Int:[String:[Int]?]]?
        private var movedWinner:[Int]?
        private var gameMode:[String]?
        private var modeSelected:Int?
    
        // Constructor de la clase
        init( context:ViewController ){
           
            parentCtxt = context
            generalPieceMoved = [UIButton]();
            
            // Modos de juegos
            gameMode = Array();
            gameMode?.append("2 Player")
            gameMode?.append("CPU")
            
            // Define las jugadas ganadoras segun ficha movida
            winningMovements = [
                1:[ "mv1":[1,2,3],"mv2":[1,4,7],"mv3":[1,5,9],"mv4":nil ],
                2:[ "mv1":[2,1,3],"mv2":[2,5,8],"mv3":nil,"mv4":nil ],
                3:[ "mv1":[3,2,1],"mv2":[3,6,9],"mv3":[3,5,7],"mv4":nil ],
                4:[ "mv1":[4,1,7],"mv2":[4,5,6],"mv3":nil,"mv4":nil ],
                5:[ "mv1":[5,6,4],"mv2":[5,1,9],"mv3":[5,3,7],"mv4":[5,8,2] ],
                6:[ "mv1":[6,9,3],"mv2":[6,5,4],"mv3":nil,"mv4":nil ],
                7:[ "mv1":[7,4,1],"mv2":[7,8,9],"mv3":[7,5,3],"mv4":nil ],
                8:[ "mv1":[8,7,9],"mv2":[8,5,2],"mv3":nil,"mv4":nil ],
                9:[ "mv1":[9,8,7],"mv2":[9,6,3],"mv3":[9,5,1],"mv4":nil ]
            ]
        }
        
        // Inicia el juego
        public func startGame(){
            isStarted = true;
            setTitle(action: "StartGame")
            currentPlayer(player: 1)
        
            // 2 jugadores por defecto
            if( modeSelected == nil ){
                modeSelected = 0
            }
            if( modeSelected == 0 ){ // 2 Player
                parentCtxt?.player2 = Player(name: "other", typeBox: "Cross")
            }else
            if( modeSelected == 1 ){ // CPU
                parentCtxt?.playerCPU = CPUPlayer(name: "other", typeBox: "Cross", context: parentCtxt!)
            }
            parentCtxt?.gameModePicker.isUserInteractionEnabled = false
            parentCtxt?.playButton?.isHidden = true
            parentCtxt?.restartButton?.isHidden = false
        }
        
        // Restaura el juego
        public func restartGame(){
            if( generalPieceMoved != nil ){  // Reinicia las fichas
                for uiboxBtn in generalPieceMoved! {
                    uiboxBtn.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                    uiboxBtn.setImage( nil, for: UIControl.State.normal )
                }
            }
            setTitle(action: "Reset")
            setAvatarGame(action: "Reset")
            parentCtxt?.prepareGame()
            parentCtxt?.gameModePicker.selectRow(0, inComponent: 0, animated: true)
            parentCtxt?.gameModePicker.isUserInteractionEnabled = true
            parentCtxt?.restartButton.isHidden = true
            parentCtxt?.playButton.isHidden = false
        }
        
        // Termina el juego
        public func gameOver(){
            isStarted = false
            setTitle(action: "GameOver")
            setAvatarGame(action: "GameOver")
            for numb in movedWinner!{
                if( generalPieceMoved != nil ){
                    for uiboxBtn in generalPieceMoved! {
                        if( uiboxBtn.tag == numb ){
                            uiboxBtn.tintColor = #colorLiteral(red: 0.1190840717, green: 0.7877874028, blue: 0.1518012053, alpha: 1)
                            break
                        }
                    }
                }
            }
            parentCtxt?.restartButton.isHidden = false
            parentCtxt?.playButton.isHidden = true
        }
        
        // Juego Empatado
        public func tiedGame(){
            isStarted = false
            setTitle(action: "TiedGame")
            setAvatarGame(action: "TiedGame")
            parentCtxt?.restartButton.isHidden = false
            parentCtxt?.playButton.isHidden = true
        }
        
        // Confirma si el juego esta finalizado
        public func gameIsFinish()->Bool{
            return isStarted
        }
        
        // Confirma si el juego esta iniciado
        public func gameIsStarted()->Bool{
            return isStarted
        }
        
        // Configura el jugador actual
        public func currentPlayer( player:Int ){
            currPlayer = player
        }
        
        // Confirma el jugador actual
        public func getCurrentPlayer()->Int{
            return currPlayer!
        }
    
        // Configura las fichas movidas en el juego
        public func setGeneralPieceMoved( movedPlayed:UIButton ){
            generalPieceMoved?.append(movedPlayed)
        }
        
        // Obtiene el tablero general de jugadas
        public func getGeneralPieceMoved()->[UIButton]{
            return generalPieceMoved!
        }
        
        // Configura el movimiento del jugador en cada uno de sus tableros
        public func setMovementBoard( movedPlayed:UIButton ){
            // Identifica el jugador actual
            setGeneralPieceMoved(movedPlayed: movedPlayed)
            switch( getCurrentPlayer() ){
                case 0:     //CPU
                    parentCtxt?.playerCPU?.setMovementBoard(movedPlayed: movedPlayed)
                    break;
                case 1:     //Player1
                    parentCtxt?.player1?.setMovementBoard(movedPlayed: movedPlayed)
                    break;
                case 2:     //Player2
                    parentCtxt?.player2?.setMovementBoard(movedPlayed: movedPlayed)
                    break;
                default:
                    break;
            }// Fin del switch
        }
        
        // Verifica el movimiento del jugador para determinar si ha ganado o no.
        public func checkPlayerMovement( movedPlayed:UIButton ){
            
            var currBoard:[Int:Bool]?
            let movements:[String:[Int]?] = (winningMovements![movedPlayed.tag])!
            var movedCompleted:Int = 0
            
            // Identifica el jugador actual
            switch( getCurrentPlayer() ){
                case 0:     //CPU
                    currBoard = parentCtxt?.playerCPU?.getPlayerBoard()
                    break;
                case 1:     //Player1
                    currBoard = parentCtxt?.player1?.getPlayerBoard()
                    break;
                case 2:     //Player2
                    currBoard = parentCtxt?.player2?.getPlayerBoard()
                    break;
                default:
                    break;
            }// Fin del switch
            
            // Checkea la jugada para determina si el jugador ha ganado
            for (_,value) in movements {
                if( value != nil ){
                    if( movedCompleted == 3 ){
                        break;
                    }else{
                        if( movedCompleted != 0 ){
                            movedCompleted = 0;
                        }
                        for numb in value! {
                            if( currBoard![numb]! ){
                                movedCompleted += 1
                            }
                            if( movedCompleted == 3 ){
                                movedWinner = value!
                                break;
                            }
                        }// fin del ciclo
                    }
                }
            }// fin del ciclo
            
            // Verifica el numero de aciertos del jugador
            if( movedCompleted == 3 ){
                gameOver();
            }else{
                // Verifica si se ha movido todas de las fichas
                if( generalPieceMoved?.count == 9 ){
                    tiedGame()
                }else{
                    
                    // Identifica el jugador actual
                    switch( getCurrentPlayer() ){
                        case 0:     //CPU
                            setTitle(action:"Player1")
                            currentPlayer(player: 1)
                            break;
                        case 1:     //Player1
                            if( modeSelected == 0 ){ // 2 Player
                                setTitle(action:"Player2")
                                currentPlayer(player: 2)
                            }else
                            if( modeSelected == 1 ){ // CPU
                                // Movimientos de la maquina
                                setTitle(action:"PlayerWithCpu")
                                currentPlayer(player: 0)
                                parentCtxt?.playerCPU?.buildStrategy()
                                
                                // Esperamos dos segundos
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    self.setMovementBoard(movedPlayed: (self.parentCtxt?.playerCPU?.getUiBoxMove())!)
                                    self.checkPlayerMovement(movedPlayed: (self.parentCtxt?.playerCPU?.getUiBoxMove())!)
                                }
                            }
                            break;
                        case 2:     //Player2
                            setTitle(action:"Player1")
                            currentPlayer(player: 1)
                            break;
                        default:
                            break;
                    }// Fin del switch
                }
            }
            
        }// fin de checkPlayerMovement
        
        // Configura el avatar del juego
        public func setAvatarGame( action:String ){
            
            // Indentifica el boton
            switch( action ){
                case "GameOver":
                    parentCtxt?.avatarGame.image = UIImage(named: "winner")
                    break;
                case "Reset":
                    parentCtxt?.avatarGame.image = nil
                    break;
                case "TiedGame":
                     parentCtxt?.avatarGame.image = UIImage(named: "tied")
                    break;
                default:
                    break;
            }// Fin del switch
            
        }// fin de setAvatarGame
        
        // Configura el titulo del juego
        public func setTitle( action:String ){
            
            // Indentifica el boton
            switch( action ){
                case "StartGame":
                    parentCtxt?.titleLabel1.text! = "turn of player 1"
                    break;
                case "Player1":
                    parentCtxt?.titleLabel1.text! = "turn of player 1"
                    break;
                case "Player2":
                    parentCtxt?.titleLabel1.text! = "turn of player 2"
                    break;
                case "Reset":
                    parentCtxt?.titleLabel1.text! = "Click on Play to start"
                    break;
                case "TiedGame":
                    parentCtxt?.titleLabel1.text! = "¡BUUUU!.. Tied Game"
                    break;
                case "GameOver":
                    if( getCurrentPlayer() == 0 ){
                        parentCtxt?.titleLabel1.text! = "CPU is Winner"
                    }else{
                        parentCtxt?.titleLabel1.text! = "Player " + String(getCurrentPlayer()) + " is Winner"
                    }
                    break;
                case "PlayerWithCpu":
                    parentCtxt?.titleLabel1.text! = "turn of the CPU"
                    break;
                default:
                    break;
            }// Fin del switch
            
        }// Fin de setTitle
        
        // Obtiene las movidas gandores del juego
        public func getWinningMovement()->[Int:[String:[Int]?]]?{
            return winningMovements!
        }
        
        // Obtiene las opciones del Picker View
        public func getGameMode()->[String]{
            return gameMode!
        }
        
        // Configura el modo de juego seleccionado
        public func setModeSelected( selected:Int ){
            modeSelected = selected
        }
        
        // Obtiene el modo de juego actual
        public func getModeSelected()->Int{
            return modeSelected!
        }
        
    }// Fin de la clase MainControl
    
    /* **** Clase Tablero Principal **** */
    class MainBoard {
        
        // Coleccion tablero de jugador
        public var playerBoard:[Int:Bool] = [
            9:false, 8:false, 7:false,
            6:false, 5:false, 4:false,
            3:false, 2:false, 1:false
        ]
        
    }// fin de la clase mainBoard
    
    /* **** Clase Jugador **** */
    class Player: MainBoard {
        
        private let playerName:String?
        private let playerTypeBox:String?
        
        // Constructor
        init( name:String, typeBox:String){
            playerName    = name
            playerTypeBox = typeBox
        }
        
        // Obtiene el tablero actual del jugador
        public func getPlayerBoard()->[Int:Bool]{
            return playerBoard
        }
        
        // Configura el movimiento del jugador en el tablero
        public func setMovementBoard( movedPlayed:UIButton ){
            playerBoard[movedPlayed.tag] = true
            movedPlayed.setImage( UIImage(named: playerTypeBox! ), for: UIControl.State.normal)
        }
        
    }// Fin de la clase Player
    
    /* **** Clase Jugador CPU **** */
    class CPUPlayer: MainBoard {
        
        private let playerName:String?
        private let playerTypeBox:String?
        private let parentCtxt:ViewController?
        private let uiBoxAll:[Int:UIButton?]?
        private var uiBoxSelected:UIButton?
        private var cpuFirstMove:[Int:[Int]]?
        private var isFirstMove:Bool?
        
        // Constructor
        init( name:String, typeBox:String, context:ViewController ){
            playerName    = "CPU"
            playerTypeBox = typeBox
            parentCtxt    = context
            isFirstMove   = true
            
            // Cajas de juego (Fichas)
            uiBoxAll = [
                1:parentCtxt?.uiBox1, 2:parentCtxt?.uiBox2, 3:parentCtxt?.uiBox3,
                4:parentCtxt?.uiBox4, 5:parentCtxt?.uiBox5, 6:parentCtxt?.uiBox6,
                7:parentCtxt?.uiBox7, 8:parentCtxt?.uiBox8, 9:parentCtxt?.uiBox9
            ]
            
            // Define la primeras jugadas que puede hacer la cpu
            cpuFirstMove = [
                7:[5], 1:[5], 3:[5], 9:[5],
                5:[7,9,1,3], 8:[7,5,9,2]
            ]
        }
        
        // Obtiene el tablero actual del jugador
        public func getPlayerBoard()->[Int:Bool]{
            return playerBoard
        }
    
        // Busca estrategias del jugador contrario y trata de anularlas
        // Si no  busca su porpia estrategia
        public func buildStrategy(){

            // Tablero de movimientos del jugador 1
            var player1Board    = parentCtxt?.player1?.getPlayerBoard()
            var playerCPUBoard  = parentCtxt?.playerCPU?.getPlayerBoard()
            var winningMovement = parentCtxt?.mainControl?.getWinningMovement()
            var pieceSelected   = 0
            
            // Obtener probabilidades de ganar de la CPU
            var possibleMovements:[Int:[String:[Int]]] = [Int:[String:[Int]]]();
            for (piece,value1) in playerCPUBoard! {
                if( value1 ){
                    for (moveKey,value2) in winningMovement![piece]!{ // 2
                        if let _ = value2 {
                            if( possibleMovements[piece] == nil ){
                                let allMoves = [moveKey:[Int]()]
                                possibleMovements.updateValue(allMoves, forKey: piece)
                            }
                            possibleMovements[piece]?[moveKey] = value2
                        }
                    }// fin ciclo 2
                }
            }// Fin del ciclo 1
            
            // Verifica la probabilidades obtenidas para la CPU y
            // selecciona la jugada si la tiene
            var winnerCPUCount = 0
            var selectedTemp = 0
            for (_,value) in possibleMovements{
                if( winnerCPUCount == 2 ){
                    if( player1Board![selectedTemp]! == false  ){
                        break
                    }else{
                        winnerCPUCount = 0
                    }
                }else{
                    winnerCPUCount = 0
                    selectedTemp = 0
                }
                for (_,value2) in value{ // 2
                    if( winnerCPUCount == 2 ){
                        if( player1Board![selectedTemp]! == false  ){
                            break
                        }else{
                            winnerCPUCount = 0
                        }
                    }else{
                        winnerCPUCount = 0
                        selectedTemp = 0
                    }
                    for pieceCheck in value2{ // 3
                        if( winnerCPUCount == 2 ){
                            if( selectedTemp == 0 ){
                                selectedTemp = pieceCheck
                            }
                            if( player1Board![selectedTemp]! == false  ){
                                break
                            }else{
                                winnerCPUCount = 0
                            }
                        }
                        if( playerCPUBoard![pieceCheck]!  ){
                            winnerCPUCount += 1
                        }else{
                            selectedTemp = pieceCheck
                        }
                    }// Fin del ciclo 3
                }// Fin del ciclo 2
            }// Fin del ciclo
            
            if( winnerCPUCount == 1 ){
                selectedTemp = 0
            }
            if( selectedTemp != 0 ){
                if( player1Board![selectedTemp]! ){
                    selectedTemp = 0
                }
            }
            
            // Verifica si la CPU tiene ficha ganadora
            if( selectedTemp == 0 ){
                
                // Obtener probabilidades del jugador
                possibleMovements = [Int:[String:[Int]]]();
                for (piece,value1) in player1Board! {
                    if( value1 ){
                        for (moveKey,value2) in winningMovement![piece]!{ // 2
                            if let _ = value2 {
                                if( possibleMovements[piece] == nil ){
                                    let allMoves = [moveKey:[Int]()]
                                    possibleMovements.updateValue(allMoves, forKey: piece)
                                }
                                possibleMovements[piece]?[moveKey] = value2
                            }
                        }// fin ciclo 2
                    }
                }// Fin del ciclo 1
                
                // Verifica movimientos ganadores obtenidos del jugador 1 y
                // selecciona la contrajugada
                var winningPiece = 0
                let boardCheked:MainBoard = MainBoard()
                for (_,value) in possibleMovements{
                    if( winningPiece == 2 ){
                        if( playerCPUBoard![selectedTemp]! == false ){
                            pieceSelected = selectedTemp
                            break
                        }else{
                            winningPiece = 0;
                        }
                    }
                    for (_,value2) in value{ // 2
                        if( winningPiece == 2 ){
                            if( playerCPUBoard![selectedTemp]! == false ){
                                pieceSelected = selectedTemp
                                break
                            }else{
                                winningPiece = 0;
                            }
                        }else{
                            winningPiece = 0
                            selectedTemp = 0
                        }
                        for pieceCheck in value2{ // 3
                            if( winningPiece == 2 ){
                                if( selectedTemp == 0 ){
                                    selectedTemp = pieceCheck
                                }
                                if( playerCPUBoard![selectedTemp]! == false ){
                                    pieceSelected = selectedTemp
                                    break
                                }else{
                                    winningPiece = 0;
                                }
                            }
                            if( player1Board![pieceCheck]! ){
                                winningPiece += 1
                            }else{
                                selectedTemp = pieceCheck
                            }
                            boardCheked.playerBoard[pieceCheck] = true
                        }// fin del ciclo 3
                    }// fin del ciclo 2
                }// Fin del ciclo
                
                if( winningPiece == 1 ){
                    selectedTemp = 0
                }
                if( pieceSelected != 0 ){
                    if( playerCPUBoard![pieceSelected]! ){
                        pieceSelected = 0
                    }
                }
            }else{
                pieceSelected = selectedTemp
            }
            
            // Si ha encontrado una jugada que contrarestar se tira
            // la pieza seleccionada
            if( pieceSelected == 0 ){
                
                // Tablero de movimientos en general
                let generalPieceMoved = parentCtxt?.mainControl?.getGeneralPieceMoved()
                var pieceAvailable:[Int]=[Int]()
                let gameGeneralBoard:MainBoard = MainBoard()
                for uiBox in generalPieceMoved! {
                    gameGeneralBoard.playerBoard[uiBox.tag] = true
                }
                for (pieceGen,value) in gameGeneralBoard.playerBoard{
                    if( value == false ){
                        pieceAvailable.append(pieceGen)
                    }
                }
                
                // ----- firstMove CPU ---- //
                var firstMovePiece = 0
                if( isFirstMove! ){
                    isFirstMove = false
                    for (piece,value1) in player1Board! {
                        if( firstMovePiece != 0 ){
                            break;
                        }
                        if( value1 ){
                            if( cpuFirstMove?[piece] == nil ){
                                break;
                            }else{
                                for firstPiece in cpuFirstMove![piece]!{
                                    firstMovePiece = firstPiece
                                    break;
                                }// fin del ciclo
                            }
                        }
                    }// fin del ciclo
                }
                
                // Si no haya primera jugada estrategica
                var selectedMove = 0
                if( firstMovePiece == 0 ){
                    //Obtener estrategia para mover
                    var movementStatistics:[Int:[String:Int]] = [Int:[String:Int]]()
                    var pieceCount = 0
                    for pieceAvail in pieceAvailable{
                        for (_,value2) in winningMovement![pieceAvail]!{ // 2
                            if let _ = value2 {
                                if( pieceCount != 0 ){
                                    pieceCount = 0
                                }
                                for piece in value2! { // 3
                                    if( player1Board![piece]! || playerCPUBoard![piece]! ){
                                    }else{
                                        if( movementStatistics[pieceAvail] == nil ){
                                            let statistics = [ "count":0, "piece":0 ]
                                            movementStatistics.updateValue(statistics, forKey: pieceAvail)
                                        }
                                        pieceCount += 1
                                        movementStatistics[pieceAvail]!["count"] = pieceCount
                                        movementStatistics[pieceAvail]!["piece"] = piece
                                    }
                                }// fin del ciclo 3
                            }
                        }// fin del ciclo 2
                    }// Fin del ciclo
                    
                    // Se analiza la mejor opcion para realizar la movida
                    var movedForStatistic = 0
                    for (_,value) in movementStatistics{
                        if( movedForStatistic < value["count"]! ){
                            movedForStatistic = value["count"]!
                            selectedMove = value["piece"]!
                        }
                    }// Fin del ciclo
                }else{
                    selectedMove = firstMovePiece
                }
                
                // Configura la fichas seleccionada
                setUiBoxMove(pieceSelect: selectedMove)
            }else{
                // Configura la fichas seleccionada
                setUiBoxMove(pieceSelect: pieceSelected)
            }
            
        }// Fin de getStrategy
        
        // Configura la ficha seleccionada
        public func setUiBoxMove( pieceSelect:Int ){
            uiBoxSelected = uiBoxAll![pieceSelect]!
        }
        
        // Obtiene la ficha seleccionada para mover
        public func getUiBoxMove()->UIButton{
            return uiBoxSelected!
        }
        
        // Configura el movimiento del jugador en el tablero
        public func setMovementBoard( movedPlayed:UIButton ){
            playerBoard[movedPlayed.tag] = true
            movedPlayed.setImage( UIImage(named: playerTypeBox! ), for: UIControl.State.normal)
        }
        
    }// Fin de la clase CPUPlayer
    
}// fin de la clase principal

