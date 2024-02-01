//
//  calculator.swift
//  swiftui-window
//
//  Created by takumi saito on 2024/01/31.
//

import SwiftUI

struct CalculatorApp: View {
    @State private var display = "0"
    @State private var currentOperation: Operation? = nil
    @State private var operand: Double? = nil
    
    static let config = WindowConfig(
        title: "Calculator",
        size: CGSize(width: 200, height: 350),
        minimizable: false,
        resizable: false,
        startPos: WindowPosMode.center
    )

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                HStack {
                    Spacer(minLength: 0)
                    Text(display)
                        .font(.largeTitle)
                }
                .padding()
                Spacer(minLength: 0)
                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(row, id: \.self) { button in
                            Button(action: {
                                self.buttonTapped(button)
                            }) {
                                Text(button)
                                    .font(.system(size: geometry.size.width * 0.1))
                                    .frame(width: self.buttonWidth(geometry: geometry), height: self.buttonWidth(geometry: geometry))
                                    .background(Color.gray)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
        }
    }

    private func buttonWidth(geometry: GeometryProxy) -> CGFloat {
        return (geometry.size.width) / 4
    }

    private func buttonTapped(_ button: String) {
        switch button {
        case "0"..."9":
            if display == "0" {
                display = button
            } else {
                display += button
            }
        case "+", "-", "×", "÷":
            operand = Double(display)
            currentOperation = Operation(rawValue: button)
            display = "0"
        case "=":
            if let operation = currentOperation,
               let operand = operand,
               let currentNumber = Double(display) {
                let result = operation.apply(operand, currentNumber)
                display = String(result)
            }
        case "C":
            display = "0"
            operand = nil
            currentOperation = nil
        default:
            break
        }
    }
}

enum Operation: String {
    case add = "+"
    case subtract = "-"
    case multiply = "×"
    case divide = "÷"

    func apply(_ a: Double, _ b: Double) -> Double {
        switch self {
        case .add:
            return a + b
        case .subtract:
            return a - b
        case .multiply:
            return a * b
        case .divide:
            return a / b
        }
    }
}

let buttons = [
    ["7", "8", "9", "÷"],
    ["4", "5", "6", "×"],
    ["1", "2", "3", "-"],
    ["0", "C", "=", "+"]
]
