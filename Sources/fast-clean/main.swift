import Foundation
import ArgumentParser
struct Constant {
  struct App {
    static let version = "1.0.0"
  }
}

@discardableResult
func shell(_ command: String) -> String {
  let task = Process()
  let pipe = Pipe()
  
  task.standardOutput = pipe
  task.standardError = pipe
  task.arguments = ["-c", command]
  task.launchPath = "/bin/zsh"
  task.launch()
  
  let data = pipe.fileHandleForReading.readDataToEndOfFile()
  let output = String(data: data, encoding: .utf8)!
  
  return output
}

struct Print {
  enum Color: String {
    case reset = "\u{001B}[0;0m"
    case black = "\u{001B}[0;30m"
    case red = "\u{001B}[0;31m"
    case green = "\u{001B}[0;32m"
    case yellow = "\u{001B}[0;33m"
    case blue = "\u{001B}[0;34m"
    case magenta = "\u{001B}[0;35m"
    case cyan = "\u{001B}[0;36m"
    case white = "\u{001B}[0;37m"
  }
  
  static func h3(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    let output = items.map { "\($0)" }.joined(separator: separator)
    print("\(Color.green.rawValue)\(output)\(Color.reset.rawValue)")
  }
  
  static func h6(_ verbose: Bool, _ items: Any..., separator: String = " ", terminator: String = "\n") {
    if verbose {
      let output = items.map { "\($0)" }.joined(separator: separator)
      print("\(output)")
    }
  }
}

extension FastClean {
  enum CacheFolder: String, ExpressibleByArgument, CaseIterable {
    case all
    case archives
    case simulators
    case deviceSupport
    case derivedData
    case previews
    case coreSimulatorCaches
  }
}

fileprivate extension FastClean.CacheFolder {
  var paths: [String] {
    switch self {
    case .archives:
      return ["~/Library/Developer/Xcode/Archives"]
    case .simulators:
      return ["~/Library/Developer/CoreSimulator/Devices"]
    case .deviceSupport:
      return ["~/Library/Developer/Xcode"]
    case .derivedData:
      return ["~/Library/Developer/Xcode/DerivedData"]
    case .previews:
      return ["~/Library/Developer/Xcode/UserData/Previews/Simulator Devices"]
    case .coreSimulatorCaches:
      return ["~/Library/Developer/CoreSimulator/Caches/dyld"]
    case .all:
      var paths: [String] = []
      for caseValue in Self.allCases {
        if caseValue != self {
          paths.append(contentsOf: caseValue.paths)
        }
      }
      return paths
    }
  }
  
  static var suggestion: String {
    let suggestion = Self.allCases.map { caseValue in
      return caseValue.rawValue
    }.joined(separator: " | ")
    return "[ \(suggestion) ]"
  }
}
//xcode-helper cache list
//xcode-helper -> struct FastClean
//cache -> FastClean.Cache
//list -> FastClean.Cache.List
//delete -> FastClean.Cache.Delete
struct FastClean: ParsableCommand {
  public static let configuration = CommandConfiguration(
    abstract: "Fast Clean",
    version: "fast-clean version \(Constant.App.version)",
    subcommands: [
      Cache.self,
    ]
  )
}

extension FastClean {
  struct Cache: ParsableCommand {
    public static let configuration = CommandConfiguration(
      abstract: "Fast Clean",
      subcommands: [
        List.self,
        Delete.self
      ]
    )
  }
}

extension FastClean.Cache {
  struct List: ParsableCommand {
    public static let configuration = CommandConfiguration(
      abstract: "Show Xcode cache files"
    )
    
    @Option(name: .shortAndLong, help: "The cache folder")
    private var cacheFolder: FastClean.CacheFolder = .all
    
    @Flag(name: .shortAndLong, help: "Show extra logging for debugging purposes.")
    private var verbose: Bool = false
    
    func run() throws {
      Print.h3("list cache files:")
      Print.h3("------------------------")
      if cacheFolder == .all {
        var allCases = FastClean.CacheFolder.allCases
        allCases.remove(at: allCases.firstIndex(of: .all)!)
        handleList(allCases)
      } else {
        handleList([cacheFolder])
      }
    }
    
    private func handleList(_ folders: [FastClean.CacheFolder]) {
      for folder in folders {
        Print.h3(folder.rawValue)
        for path in folder.paths {
          let cmd = "du -hs \(path)"
          Print.h6(verbose, cmd)
          let output =  shell(cmd)
          print(output)
        }
      }
    }
  }
}
extension FastClean.Cache {
    struct Delete: ParsableCommand {
        @Option(name: .shortAndLong, help: "The cache folder to delete")
        private var cacheFolder: FastClean.CacheFolder = .all
        
        @Flag(name: .shortAndLong, help: "Confirm deletion without prompt")
        private var force: Bool = false
        
        @Flag(name: .shortAndLong, help: "Show extra logging")
        private var verbose: Bool = false
        
        func run() throws {
            Print.h3("Preparing to delete cache files:")
            Print.h3("------------------------------")
            
            let paths = cacheFolder.paths
            let totalSize = calculateTotalSize(paths: paths)
            
            Print.h3("Total size to be freed: \(totalSize)")
            
            if !force {
                Print.h3("Are you sure you want to delete these files? [y/N]")
                guard readLine()?.lowercased() == "y" else {
                    Print.h3("Deletion cancelled")
                    return
                }
            }
            
            deleteFiles(paths: paths)
        }
        
        private func calculateTotalSize(paths: [String]) -> String {
            var totalBytes: Int64 = 0
            for path in paths {
                let cmd = "du -sk \(path) | awk '{print $1}'"
                let output = shell(cmd).trimmingCharacters(in: .whitespacesAndNewlines)
                if let kb = Int64(output) {
                    totalBytes += kb * 1024
                }
            }
            return ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file)
        }
        
        private func deleteFiles(paths: [String]) {
            for path in paths {
                Print.h3("Deleting: \(path)")
                let cmd = "rm -rf \(path)"
                Print.h6(verbose, "Executing: \(cmd)")
                let output = shell(cmd)
                if !output.isEmpty {
                    Print.h6(verbose, "Output: \(output)")
                }
            }
            Print.h3("Deletion complete")
        }
    }
}

FastClean.main()

