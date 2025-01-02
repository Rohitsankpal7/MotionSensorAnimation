//
//  ContentView.swift
//  MotionSensorAnimation
//
//  Created by Rohit Sankpal on 02/01/25.
//

import SwiftUI
import CoreMotion

struct ContentView: View {
    @StateObject private var motionManager = MotionManager()
    @State private var balls: [Ball] = []
    @State private var timer: Timer? = nil
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(balls.indices, id: \.self) { index in
                    Circle()
                        .fill(balls[index].color)
                        .frame(width: balls[index].size, height: balls[index].size)
                        .position(balls[index].position)
                }
            }
            .onAppear {
                createBalls(in: geometry.size)
                startMotionUpdates(in: geometry.size)
            }
            .onDisappear {
                motionManager.stopUpdates()
                timer?.invalidate()
            }
        }
    }
    
    private func createBalls(in size: CGSize) {
        balls = (1...50).map { _ in
            Ball(
                position: CGPoint(
                    x: CGFloat.random(in: 20...size.width - 50),
                    y: CGFloat.random(in: 50...size.height - 50)
                ),
                color: Color(
                    hue: Double.random(in: 0...1),
                    saturation: 0.5,
                    brightness: 0.9
                ),
                size: CGFloat.random(in: 20...50),
                velocity: CGPoint(x: CGFloat.random(in: -2...50), y: CGFloat.random(in: -2...50))
            )
        }
    }
    
    private func startMotionUpdates(in size: CGSize) {
        motionManager.startUpdates()
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            for index in balls.indices {
                let dx = motionManager.tilt.x * 10
                let dy = motionManager.tilt.y * 10
                
                var newX = balls[index].position.x + CGFloat(dx)
                var newY = balls[index].position.y - CGFloat(dy)
                
                newX = max(25, min(size.width - 25, newX))
                newY = max(25, min(size.height - 25, newY))
                
                balls[index].position = CGPoint(x: newX, y: newY)
            }
            
            for i in balls.indices {
                for j in balls.indices where i != j {
                    let distance = hypot(
                        balls[i].position.x - balls[j].position.x,
                        balls[i].position.y - balls[j].position.y
                    )
                    let minDistance = (balls[i].size + balls[j].size) / 2
                    if distance < minDistance {
                        // Calculate the overlap
                        let overlap = minDistance - distance
                        let dx = balls[j].position.x - balls[i].position.x
                        let dy = balls[j].position.y - balls[i].position.y
                        let angle = atan2(dy, dx)
                        
                        // Push balls apart proportionally
                        balls[i].position.x -= cos(angle) * overlap / 2
                        balls[i].position.y -= sin(angle) * overlap / 2
                        balls[j].position.x += cos(angle) * overlap / 2
                        balls[j].position.y += sin(angle) * overlap / 2
                        
                        // Add a slight velocity adjustment to avoid repeated sticking
                        balls[i].velocity.x -= cos(angle) * 0.1
                        balls[i].velocity.y -= sin(angle) * 0.1
                        balls[j].velocity.x += cos(angle) * 0.1
                        balls[j].velocity.y += sin(angle) * 0.1
                    }
                }
            }
            
            balls.removeAll { $0.size == 0 }
        }
    }
}

struct Ball: Identifiable {
    let id = UUID()
    var position: CGPoint
    var color: Color
    var size: CGFloat
    var velocity: CGPoint
}
