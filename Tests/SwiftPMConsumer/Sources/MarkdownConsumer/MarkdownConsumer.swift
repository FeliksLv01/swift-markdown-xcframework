import Markdown

public enum MarkdownConsumer {
    public static func parse(_ source: String) -> Document {
        Document(parsing: source)
    }
}
