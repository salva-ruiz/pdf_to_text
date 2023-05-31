# PDFToText

An Elixir library that allows to convert a PDF file into a string or stream
using the required `pdftotext` command line tool that can be downloaded from
[XpdfReader](https://xpdfreader.com).

By default the `-raw -nopgbrk -enc UTF-8` conversion parameters are used but
these can be modified using the `args` keyword in the `opts` parameter.

## Examples

    # Conversion with default arguments
    PDFToText.text("file.pdf")

    # Conversion with custom arguments
    PDFToText.stream("file.pdf", args: ["-raw", "-nopgbrk", "-enc", "UTF-8"])

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
