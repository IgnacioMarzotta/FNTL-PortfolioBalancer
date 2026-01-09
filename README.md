<h1>Portfolio Rebalancer (Ruby)</h1>

Este proyecto implementa un módulo simple de gestión y rebalanceo de portafolios de inversión, como parte de una aplicación de trading o inversiones personales para postular a la posición de Software Engineer en Fintual.

El objetivo es calcular el estado actual de un portafolio y sugerir compras o ventas necesarias para alinearlo con una distribución objetivo definida previamente.

<h2>Enunciado</h2>

    You’re building a portfolio management module, part of a personal investments and trading app. Construct a simple Portfolio class that has a collection of Stocks. Assume each Stock has a “Current Price” method that receives the last available price. Also, the Portfolio class has a collection of “allocated” Stocks that represents the distribution of the Stocks the Portfolio is aiming (i.e. 40% META, 60% APPL).
    Provide a portfolio rebalance method to know which Stocks should be sold and which ones should be bought to have a balanced Portfolio based on the portfolio’s allocation.

<h2>Descripcion de la solucion</h2>
Un Portfolio contiene una colección de Stocks, donde cada stock tiene:
<ul>
    <li>Nombre (ticker)</li>
    <li>Precio actual</li>
    <li>Cantidad (puede ser decimal)</li>
    <li>Valor total (precio × cantidad)</li>
</ul>

Además, el portafolio define una estructura de allocation, que representa la distribución objetivo del valor total del portafolio (por ejemplo: 40% META, 60% AAPL). A partir de esto, el sistema:
<ol>
    <li>Calcula el valor total del portafolio.</li>
    <li>Muestra estadísticas actuales (valor, porcentaje actual vs objetivo).</li>
    <li>Genera un plan de rebalanceo, indicando cuánto comprar o vender de cada stock para alcanzar la distribución objetivo sin cambiar el valor total del portafolio.</li>
</ol>

<hr>

<h4>Logica de 'Rebalance':</h4>
    Para cada stock:

    Se calcula su valor objetivo según el porcentaje definido en allocation.

    Se compara con su valor actual.

    La diferencia determina:

        Compra (si el valor actual es menor al objetivo).

        Venta (si el valor actual es mayor al objetivo).

Las cantidades se manejan como float para permitir mayor precisión.

Se considera un pequeño margen de tolerancia para evitar operaciones irrelevantes por errores de punto flotante.

<hr>

<h4>Consideraciones de diseño:</h4>

    1. Todos los stocks deben tener allocation: El algoritmo asume que el 100% del valor del portafolio está distribuido entre los stocks definidos. En un escenario real, esta restricción podría relajarse para permitir cash u otros activos no asignados.

    2. Modelo simplificado de Stock: Técnicamente, el modelo representa una posición en un stock (cantidad + precio), no el stock como entidad financiera. En un sistema real, esto podría separarse en modelos Stock y Position, pero se mantuvo un único modelo para preservar la claridad del ejercicio sin afectar la lógica de rebalanceo.

<h2>Casos de prueba</h2>

1. Precios con Decimales (Precisión de Mercado)
```
stocks = [
    Stock.new(name: "META", price: 485.32, quantity: 10),
    Stock.new(name: "AAPL", price: 189.15, quantity: 15),
    Stock.new(name: "GOOG", price: 142.08, quantity: 8),
    Stock.new(name: "AMZN", price: 175.22, quantity: 12),
    Stock.new(name: "NFLX", price: 605.88, quantity: 5),
    Stock.new(name: "TSLA", price: 163.57, quantity: 20)
]

allocation = {
    "META": 0.20,
    "AAPL": 0.20,
    "GOOG": 0.15,
    "AMZN": 0.15,
    "NFLX": 0.15,
    "TSLA": 0.15
}
```
2. Allocation para Stock Inexistente

```
stocks = [
    Stock.new(name: "META", price: 100, quantity: 5),
    Stock.new(name: "AAPL", price: 100, quantity: 5),
    Stock.new(name: "GOOG", price: 100, quantity: 5),
    Stock.new(name: "AMZN", price: 100, quantity: 5),
    Stock.new(name: "NFLX", price: 100, quantity: 5)
]

allocation = {
    "META" : 0.2,
    "AAPL" : 0.2,
    "GOOG" : 0.2,
    "AMZN" : 0.2,
    "NVDA" : 0.2
}
```

3. Stock sin Allocation Definido
```
stocks = [
    Stock.new(name: "META", price: 100, quantity: 2),
    Stock.new(name: "AAPL", price: 100, quantity: 2),
    Stock.new(name: "GOOG", price: 100, quantity: 2),
    Stock.new(name: "AMZN", price: 100, quantity: 2),
    Stock.new(name: "NFLX", price: 100, quantity: 2),
    Stock.new(name: "MSFT", price: 100, quantity: 2)
]

allocation = {
    "META": 0.2,  
    "AAPL": 0.2,
    "GOOG": 0.2,
    "AMZN": 0.2,
    "NFLX": 0.2
}
```

4. Portafolio "En Quiebra" (Precios en 0)
```
stocks = [
    Stock.new(name: "META", price: 0, quantity: 10),
    Stock.new(name: "AAPL", price: 0, quantity: 10),
    Stock.new(name: "GOOG", price: 0, quantity: 10),
    Stock.new(name: "AMZN", price: 0, quantity: 10),
    Stock.new(name: "NFLX", price: 0, quantity: 10),
    Stock.new(name: "TSLA", price: 0, quantity: 10)
]

allocation = {
    "META": 0.15,
    "AAPL": 0.15,
    "GOOG": 0.20,
    "AMZN": 0.20,
    "NFLX": 0.15,
    "TSLA": 0.15
}
```

5. Inversión Inicial (Cantidades en 0)
```
stocks = [
    Stock.new(name: "META", price: 500, quantity: 10),
    Stock.new(name: "AAPL", price: 150, quantity: 20),
    Stock.new(name: "GOOG", price: 140, quantity: 0),
    Stock.new(name: "AMZN", price: 180, quantity: 0),
    Stock.new(name: "NFLX", price: 600, quantity: 0)
]

allocation = {
    "META": 0.2,
    "AAPL": 0.2,
    "GOOG": 0.2,
    "AMZN": 0.2,
    "NFLX": 0.2
}
```

6. Error de Configuración de Pesos (150%)
```
stocks = [
    Stock.new(name: "META", price: 100, quantity: 1),
    Stock.new(name: "AAPL", price: 100, quantity: 1),
    Stock.new(name: "GOOG", price: 100, quantity: 1),
    Stock.new(name: "AMZN", price: 100, quantity: 1),
    Stock.new(name: "NFLX", price: 100, quantity: 1)
]

allocation = {
    "META": 0.3,
    "AAPL": 0.3,
    "GOOG": 0.3,
    "AMZN": 0.3,
    "NFLX": 0.3
}
```