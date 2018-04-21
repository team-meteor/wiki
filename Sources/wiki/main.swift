import Foundation

let current = FileManager.default.currentDirectoryPath
let headerURL = URL(fileURLWithPath: current).appendingPathComponent("header.md")
let footerURL = URL(fileURLWithPath: current).appendingPathComponent("footer.md")
let metaURL = URL(fileURLWithPath: current).appendingPathComponent("meta.csv")
let outputURL = URL(fileURLWithPath: current).appendingPathComponent("README.md")
let gistURLString = "https://gist.github.com/"

typealias Document = (String, String) // gist id, title

do {
  var outputString = ""
  if let headerString = try? String(contentsOf: headerURL, encoding: .utf8) {
    outputString += headerString
  }
  var series = [String: [Document]]()
  var singles = [Document]()
  
  let metaString = try String(contentsOf: metaURL, encoding: .utf8)
  let lines = metaString.components(separatedBy: "\n")
    .filter { $0.count > 0 }
  
  for (index, line) in lines.enumerated() {
    if index == 0 || index == 1 {
      continue
    }
    let words = line.components(separatedBy: ",").map {
      $0.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    if words.count == 3 {
      let (id, docTitle, seriesTitle) = (words[0], words[1], words[2])
      if var series = series[seriesTitle] {
        series.append(Document(id, docTitle))
      } else {
        series[seriesTitle] = [Document(id, docTitle)]
      }
    } else if words.count == 2 {
      let (id, docTitle) = (words[0], words[1])
      singles.append(Document(id, docTitle))
    }
  }
  
  let sortedSeries = series.map { (arg) -> (String, [Document]) in
    let (title, documents) = arg
    let sortedDocuments = documents.sorted {
      return $0.1 < $1.1
    }
    return (title, sortedDocuments)
    }.sorted {
      return $0.0 < $1.0
  }
  
  outputString += "\n### 2018\n"
  sortedSeries.forEach { title, documents in
    outputString += "- \(title)"
    documents.forEach {
      outputString += "\n  - \($0) [read](\(gistURLString)\($1))\n"
    }
  }
  singles.forEach {
    outputString += "- \($0) [read](\(gistURLString)\($1))\n"
  }
  outputString += "\n"
  
  if let footerString = try? String(contentsOf: footerURL, encoding: .utf8) {
    outputString += footerString
  }
  try outputString.write(to: outputURL, atomically: true, encoding: .utf8)
  
} catch {
  print("no metafile.")
}
