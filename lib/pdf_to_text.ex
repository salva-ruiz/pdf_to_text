defmodule PDFToText do
  @moduledoc """
  This module allows to convert a PDF file into a string or stream using the
  required `pdftotext` command line tool that can be downloaded from
  [XpdfReader](https://xpdfreader.com).

  By default the `-raw -nopgbrk -enc UTF-8` conversion parameters are used but
  these can be modified using the `args` keyword in the `opts` parameter.
  """

  @doc """
  Converts a PDF file into a string.

  ## Examples

      # Conversion with default arguments
      PDFToText.text("file.pdf")

      # Conversion with custom arguments
      PDFToText.text("file.pdf", args: ["-raw", "-nopgbrk", "-enc", "UTF-8"])
  """
  @spec text(Path.t(), [{:pdftotext, String.t()}, {:pdftotext_opts, [String.t()]}]) ::
          String.t() | {:error, String.t()}
  def text(pdf_filename, opts \\ []) when is_binary(pdf_filename) do
    conversion(pdf_filename, opts)
  end

  @doc """
  Converts a PDF file into a list of strings using a stream.

  ## Examples

      # Conversion with default arguments
      PDFToText.stream("file.pdf")

      # Conversion with custom arguments
      PDFToText.stream("file.pdf", args: ["-raw", "-nopgbrk", "-enc", "UTF-8"])
  """
  @spec stream(Path.t(), [{:pdftotext, String.t()}, {:pdftotext_opts, [String.t()]}]) ::
          File.Stream.t() | {:error, String.t()}
  def stream(pdf_filename, opts \\ []) when is_binary(pdf_filename) do
    with {:ok, output_filename} <- Briefly.create(),
         :ok <- conversion(pdf_filename, Keyword.merge(opts, output: output_filename)) do
      output_filename
      |> File.stream!()
      |> Stream.map(fn line -> String.trim_trailing(line) end)
    else
      {:too_many_attemps, _, _} ->
        {:error, "could not create temporary file"}

      {:no_tmp, _} ->
        {:error, "could not create temporary file"}

      {:error, msg} ->
        {:error, msg}
    end
  end

  @pdftotext "pdftotext"
  @default_args ~w(-raw -nopgbrk -enc UTF-8)
  @stdout "-"

  defp conversion(pdf_filename, opts) when is_binary(pdf_filename) and is_list(opts) do
    pdftotext = Keyword.get(opts, :pdftotext, @pdftotext)
    args = Keyword.get(opts, :pdftotext_opts, @default_args)
    output = Keyword.get(opts, :output, @stdout)

    with executable when not is_nil(executable) <- System.find_executable(pdftotext),
         true <- File.exists?(pdf_filename),
         {text, 0} <- System.cmd(executable, args ++ [pdf_filename, output]) do
      if output == @stdout do
        text
      else
        :ok
      end
    else
      nil ->
        {:error, ~s(executable "#{pdftotext}" not found)}

      false ->
        {:error, ~s(input file "#{pdf_filename}" not found)}

      {_, 1} ->
        {:error, ~s(the command "#{pdftotext}" with #{args} options returned an error)}
    end
  end
end
