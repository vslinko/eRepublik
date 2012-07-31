data <- read.csv("result.csv", col.names=c(
    "time", "country", "product", "quality", "price", "stock"
))
data$time <- as.POSIXct(data$time, origin="1970-01-01")

layouts <- list(
    c(1),
    c(),
    c(),
    c(),
    matrix(c(1, 1, 1, 2, 2, 2,
             3, 3, 4, 4, 5, 5), 2, 6, byrow = TRUE),
    c(),
    matrix(c(1, 1, 2, 2,
             1, 1, 3, 3,
             4, 5, 6, 7), 3, 4, byrow = TRUE)
)

for (product in unique(data$product)) {
    products <- data[data$product == product, ]

    qualities <- sort(unique(products$quality))
    colors <- rainbow(length(qualities))

    layout(layouts[[length(qualities)]])

    for (quality in qualities) {
        q_products = products[products$quality == quality, ]
        plot(q_products$time, q_products$price, "l", col=colors[quality], xlab="Time", ylab="Price")

        title(paste(product, quality))
    }
}
