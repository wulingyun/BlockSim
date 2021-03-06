#' Find the faithful order of blocks
#' 
#' 
#' @export
maxcord <- function(adj_matrix, max_discord = 10)
{
  dist_matrix <- shortest_distances(adj_matrix)
  fb <- find_faithful_blocks(adj_matrix, max_discord, dist_matrix)
  weight <- numeric(dim(adj_matrix)[1])
  weight[fb] <- 1
  past_future <- block_distances(adj_matrix, weight, dist_matrix)
  order(order(past_future$future, weight, -past_future$past, decreasing = TRUE, na.last = TRUE))
}


#' Find faithful blocks
#'
#' @import igraph
#'
#' @export
find_faithful_blocks <- function(adj_matrix, max_discord = 10, dist_matrix = NULL)
{
  d <- block_discords(adj_matrix, dist_matrix)
  d[d <= max_discord] <- 0
  d[d > max_discord] <- 1
  largest_ivs(graph_from_adjacency_matrix(d, mode = "undirected"))[[1]]
}


#' Calculate block distances
#'
#'
#' @export
block_distances <- function(adj_matrix, block_weight = NULL, dist_matrix = NULL)
{
  if (is.null(dist_matrix)) x <- shortest_distances(adj_matrix)
  else x <- dist_matrix
  y <- x > 0 & x < Inf
  if (is.null(block_weight))
  {
    past <- rowSums(y)
    future <- colSums(y)
  }
  else
  {
    past <- as.vector(y %*% block_weight)
    future <- as.vector(block_weight %*% y)
  }
  list(distances = x, past = past, future = future)
}


#' Calculate block discords
#'
#'
#' @export
block_discords <- function(adj_matrix, dist_matrix = NULL)
{
  if (is.null(dist_matrix)) x <- shortest_distances(adj_matrix)
  else x <- dist_matrix
  n <- dim(adj_matrix)[1]
  discords <- matrix(0, n, n)
  d <- apply(x[colSums(adj_matrix) == 0, , drop = FALSE], 2, min)
  past <- lapply(1:n, function(i) x[i, ] < Inf)
  future <- lapply(1:n, function(i) x[, i] < Inf)
  for (i in 2:n)
  {
    for (j in 1:(i-1))
    {
      if (x[i, j] == Inf && x[j, i] == Inf)
      {
        p <- past[[i]] & past[[j]]
        f <- future[[i]] & future[[j]]
        discords[i, j] <- discords[j, i] <- min(x[i, p] + x[j, p]) + min(x[f, i] + x[f, j], d[i] + d[j] + 2)
      }
    }
  }
  discords
}


#' Calculate the length of main chain
#' 
#' 
#' @import igraph
#' 
#' @export
length_of_main_chain <- function(adj_matrix)
{
  g <- graph_from_edgelist(which(adj_matrix == 1, arr.ind = TRUE), directed = TRUE)
  edge_attr(g, "weight") <- -1
  d <- distances(g, 1, mode = "in", algorithm = "bellman-ford")
  - min(d)
}


#' Calculate the transactions per block
#' 
#' 
#' @export
tx_per_block <- function(block_size = 1)
{
  block_size * 1024^2 / 500
}


#' Calculate the transactions per second
#' 
#' 
#' @export
tx_per_second <- function(effective_block_rate, block_size = 1)
{
  tx_per_block(block_size) * effective_block_rate
}
