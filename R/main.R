#' Path-based access and manipulation for R lists
#'
#' The slash class provides tools for working with hierarchical R lists using
#' path-like strings (e.g., "a/b/c"). Rather than creating a new data structure,
#' it adds convenient path-based access methods to standard R lists, supporting:
#' - Both named and numeric (1-based) indexing
#' - Strict mode for error checking
#' - Various operations for list manipulation
#'
#' @importFrom R6 R6Class
#' @export
slash <- R6::R6Class(
  "slash",
  public = list(
    #' @description Create a new slash object
    #' @param data Initial data (must be a list)
    #' @param strict If TRUE, attempts to access non-existent paths will error
    #' @return A new `slash` object
    initialize = function(data = list(), strict = FALSE) {
      if (!is.logical(strict)) {
        stop("'strict' parameter must be logical")
      }

      if (is.na(strict)) {
        stop("'strict' parameter cannot be NA")
      }

      if (!typeof(data) == "list") {
        datatype <- typeof(data)
        stop(paste0("type of list is expected for 'data', not ", datatype))
      }

      private$.data <- data
      private$.strict <- strict
    },

    #' @description Get value at specified path
    #' @param path Path to the element (e.g., "a/b/c" or "1/2/3")
    #' @param default Value to return if path doesn't exist (NULL by default)
    #' @return The value at the specified path, or default if not found
    get = function(path = NULL, default = NULL) {
      if (is.null(path)) {
        return(private$.data)
      }
      private$.validate_path(path)
      keys <- private$.split_path(path)
      result <- private$.nested_get(private$.data, keys, default)

      if (private$.strict && is.null(result) && !self$exists(path)) {
        stop(sprintf("Element at path '%s' does not exist", path))
      }

      return(result)
    },

    #' @description Set value at specified path
    #' @param path Path to the element
    #' @param value Value to set
    #' @return The slash object (invisibly) for chaining
    set = function(path, value) {
      private$.validate_path(path)
      keys <- private$.split_path(path)
      private$.data <- private$.nested_set(private$.data, keys, value)
      invisible(self)
    },

    #' @description Check if path exists
    #' @param path Path to check
    #' @return TRUE if path exists, FALSE otherwise
    exists = function(path) {
      private$.validate_path(path)
      keys <- private$.split_path(path)

      # Special case for root path
      if (length(keys) == 0) return(TRUE)

      data <- private$.data
      for (i in seq_along(keys)) {
        key <- keys[[i]]

        if (is.numeric(key)) {
          if (!is.list(data) || key < 1 || key > length(data)) {
            return(FALSE)
          }
        } else {
          if (!is.list(data) || !key %in% names(data)) {
            return(FALSE)
          }
        }

        # Move to next level
        data <- data[[key]]

        # Return TRUE if we're at the final key, even if value is NULL
        if (i == length(keys)) return(TRUE)
      }

      return(FALSE)
    },

    #' @description Delete element at specified path
    #' @param path Path to delete
    #' @return The slash object (invisibly) for chaining
    delete = function(path) {
      private$.validate_path(path)
      keys <- private$.split_path(path)
      private$.data <- private$.nested_delete(private$.data, keys)
      invisible(self)
    },

    #' @description Clear all data
    #' @return The slash object (invisibly) for chaining
    clear = function() {
      private$.data <- list()
    },

    #' @description Get all data as a list
    #' @return The complete data structure
    get_all = function() {
      private$.data
    },

    #' @description Print summary of slash object
    #' @param show_full If TRUE, shows full structure (FALSE by default)
    print = function(show_full = FALSE) {
      cat("slash object (", ifelse(private$.strict, "strict", "non-strict"), " mode)\n", sep = "")
      if (show_full) {
        cat("Full dictionary structure:\n")
        str(private$.data)
      } else {
        cat("Use $get() or $get_all() to view contents\n")
        cat("Available Paths:\n")
        cat(paste0("- ", self$list_paths(), collapse = "\n"))
      }
    },

    #' @description Print list structure at path
    #' @param path Path to print (NULL for root)
    print_list = function(path = NULL) {
      res <- self$get(path)
      dput(res)
    },

    #' @description List all available paths
    #' @return Character vector of all paths in the data structure
    list_paths = function() {
      private$.find_paths(private$.data)
    },

    #' @description Check if in strict mode
    #' @return TRUE if in strict mode, FALSE otherwise
    is_strict = function() {
      private$.strict
    },

    #' @description Set strict mode
    #' @param strict Logical value for strict mode
    #' @return The slash object (invisibly) for chaining
    set_strict = function(strict) {
      private$.strict <- strict
      invisible(self)
    },

    #' @description Filter paths by regex pattern
    #' @param pattern Regex pattern to match against paths
    #' @param ignore_case TRUE to ignore cases, FALSE otherwise.
    #' Defaults to FALSE.
    #' @return Character vector of matching paths
    filter_paths = function(pattern, ignore_case = FALSE) {
      paths <- self$list_paths()
      grep(pattern, paths, ignore.case = ignore_case, value = TRUE)
    },

    #' @description Print a tree-like diagram of the list structure
    #' @param path Optional starting path (NULL for root)
    #'
    print_tree = function(path = NULL) {
      if (!is.null(path) && !self$exists(path)) {
        stop(sprintf("Path '%s' not found", path))
      }

      start_data <- self$get(path)
      start_label <- if (is.null(path)) "\033[1;36m<root>\033[0m" else paste0("\033[1;36m", path, "\033[0m")

      cat(start_label, "\n")
      private$.print_tree_recursive(start_data, prefix = "")
    }

  ),

  private = list(
    .data = NULL,
    .strict = FALSE,

    .validate_path = function(path) {
      if (!is.null(path) && length(path) == 1 && trimws(path) == "") {
        stop("Please provide a valid path")
      }

      if (!is.character(path) || length(path) != 1) {
        stop("Path must be a single character string")
      }
      if (grepl("^/|/$", path)) {
        stop("Path cannot start or end with '/'")
      }
      if (grepl("//", path)) {
        stop("Path cannot contain empty keys (consecutive '/')")
      }
    },

    .split_path = function(path) {
      parts <- strsplit(path, "/", fixed = TRUE)[[1]]
      lapply(parts, function(x) {
        if (grepl("^[1-9][0-9]*$", x)) {  # Only positive integers
          num <- as.numeric(x)
          if (num == 0) stop("Array indices must be >= 1 (R is 1-based)")
          num
        } else {
          x
        }
      })
    },

    .nested_get = function(data, keys, default) {
      if (length(keys) == 0) return(data)
      key <- keys[[1]]

      if (is.numeric(key)) {
        if (key < 1 || key > length(data)) return(default)
        if (!is.list(data)) return(default)
        if (length(keys) == 1) {
          return(data[[key]])
        } else {
          return(private$.nested_get(data[[key]], keys[-1], default))
        }
      } else {
        # Named access
        if (!is.list(data)) return(default)
        if (!key %in% names(data)) return(default)
        if (length(keys) == 1) {
          return(data[[key]])
        } else {
          return(private$.nested_get(data[[key]], keys[-1], default))
        }
      }
    },

    .nested_set = function(data, keys, value) {
      if (length(keys) == 1) {
        key <- keys[[1]]
        if (is.numeric(key)) {
          if (key < 1) stop("Key indices must be >= 1")
          if (key > length(data)) {
            length(data) <- key
          }
          if (is.null(value)) {
            data[key] <- list(NULL)
          } else {
            data[[key]] <- value
          }
        } else {
          if (is.null(value)) {
            data[key] <- list(NULL)
          } else {
            data[[key]] <- value
          }
        }
        return(data)
      }

      key <- keys[[1]]
      if (!is.list(data)) {
        data <- list()
      }

      if (is.numeric(key)) {
        if (key < 1) stop("Array indices must be >= 1")
        if (key > length(data)) {
          length(data) <- key
        }
        if (!is.list(data[[key]])) {
          data[[key]] <- list()
        }
      } else {
        if (!key %in% names(data)) {
          data[[key]] <- list()
        } else if (!is.list(data[[key]])) {
          data[[key]] <- list()
        }
      }

      data[[key]] <- private$.nested_set(data[[key]], keys[-1], value)
      return(data)
    },

    .nested_delete = function(data, keys) {
      if (length(keys) == 1) {
        key <- keys[[1]]
        if (is.numeric(key)) {
          if (key >= 1 && key <= length(data)) {
            data[[key]] <- NULL
          }
        } else {
          data[[key]] <- NULL
        }
      } else {
        key <- keys[[1]]
        if (is.list(data)) {
          if (is.numeric(key)) {
            if (key >= 1 && key <= length(data)) {
              data[[key]] <- private$.nested_delete(data[[key]], keys[-1])
              if (length(data[[key]]) == 0) data[[key]] <- NULL
            }
          } else {
            if (key %in% names(data)) {
              data[[key]] <- private$.nested_delete(data[[key]], keys[-1])
              if (length(data[[key]]) == 0) data[[key]] <- NULL
            }
          }
        }
      }
      return(data)
    },

    .find_paths = function(data, current_path = "") {
      paths <- character(0)

      if (length(data) == 0) {
        if (nzchar(current_path)) {
          return(current_path)
        }
        return(character(0))
      }

      keys <- names(data)
      for (i in seq_along(data)) {
        # Determine the key: use name if available, else numeric index
        key <- if (!is.null(keys) && !is.na(keys[i]) && nzchar(keys[i])) keys[i] else as.character(i)

        new_path <- if (nzchar(current_path)) paste0(current_path, "/", key) else key

        if (is.list(data[[i]])) {
          paths <- c(paths, new_path)
          paths <- c(paths, private$.find_paths(data[[i]], new_path))
        } else {
          paths <- c(paths, new_path)
        }
      }

      unique(paths)
    },

    .print_tree_recursive = function(x, prefix = "") {
      if (!is.list(x)) {
        cat(prefix, "\033[1;33m", as.character(x), "\033[0m\n", sep = "")
        return()
      }

      keys <- names(x)
      if (length(x) == 0) {
        cat(prefix, "\033[1;31m<empty>\033[0m\n", sep = "")
        return()
      }

      for (i in seq_along(x)) {
        is_last <- i == length(x)
        key <- if (!is.null(keys) && !is.na(keys[i]) && nzchar(keys[i])) keys[i] else as.character(i)
        val <- x[[i]]

        # Draw the tree structure with ASCII characters
        if (is_last) {
          cat(prefix, "\033[1;34m`-- \033[0m", sep = "")
          new_prefix <- paste0(prefix, "    ")
        } else {
          cat(prefix, "\033[1;34m|-- \033[0m", sep = "")
          new_prefix <- paste0(prefix, "\033[1;34m|   \033[0m")
        }

        # Colorize the key
        colored_key <- paste0("\033[1;32m", key, "\033[0m")

        if (is.list(val)) {
          # For lists, show the key and recurse
          cat(colored_key, "\033[1;35m:\033[0m\n", sep = "")
          private$.print_tree_recursive(val, new_prefix)
        } else {
          # For values, show key: value
          val_str <- if (is.null(val)) "\033[1;31mNULL\033[0m" else paste0("\033[1;33m", as.character(val), "\033[0m")
          cat(colored_key, "\033[1;35m:\033[0m ", val_str, "\n", sep = "")
        }
      }
    }
  )
)
