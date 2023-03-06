import axios from "axios";
import { Configuration } from "./configuration";

export const ApiEndpoint =
  process.env.REACT_APP_API_URL === undefined
    ? ""
    : process.env.REACT_APP_API_URL;

export const AxiosInstance = axios.create({
  baseURL: ApiEndpoint + "/",
  headers: {
    "Content-type": "application/json",
  },
});

export const DefaultConfig = new Configuration({
  basePath: "armadillo",
});
