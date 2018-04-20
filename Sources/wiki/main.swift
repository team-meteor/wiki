import Foundation

let current = FileManager.default.currentDirectoryPath
let headerURL = URL(fileURLWithPath: current).appendingPathComponent("header.md")
let footerURL = URL(fileURLWithPath: current).appendingPathComponent("footer.md")
let metaURL = URL(fileURLWithPath: current).appendingPathComponent("meta.md")
let outputURL = URL(fileURLWithPath: current).appendingPathComponent("README.md")
let gistURLString = "https://gist.github.com/"

do {
  var outputString = ""
  if let headerString = try? String(contentsOf: headerURL, encoding: .utf8) {
    outputString += headerString
  }
  var dict = [String: String]()
  let metaString = try String(contentsOf: metaURL, encoding: .utf8)
  let lines = metaString.components(separatedBy: "\n")
    .filter { $0.count > 0 }
  
  lines.forEach {
    let words = $0.components(separatedBy: " ")
    if words.count == 2 {
      dict[words[0]] = words[1] // title, url
    }
  }
  
  outputString += "\n"
  dict.sorted { first, second in
    return first.key < second.key
    }.forEach {
    outputString += "- \($0) [read](\($1))\n"
  }
  outputString += "\n"
  
  if let footerString = try? String(contentsOf: footerURL, encoding: .utf8) {
    outputString += footerString
  }
  try outputString.write(to: outputURL, atomically: true, encoding: .utf8)
  
} catch {
  print("no metafile.")
}
