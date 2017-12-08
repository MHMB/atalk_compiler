del *.class
del *.tokens
del Atalk*.java
java org.antlr.v4.Tool Atalk.g4
javac *.java
grun Atalk program -gui <.\test.atk