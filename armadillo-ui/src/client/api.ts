/* tslint:disable */
/* eslint-disable */
/**
 * Armadillo API
 * This is a api spec for Armadillo
 *
 * The version of the OpenAPI document: 0.0.1
 * Contact: holmes89@gmail.com
 *
 * NOTE: This class is auto generated by OpenAPI Generator (https://openapi-generator.tech).
 * https://openapi-generator.tech
 * Do not edit the class manually.
 */


import { Configuration } from './configuration';
import globalAxios, { AxiosPromise, AxiosInstance, AxiosRequestConfig } from 'axios';
// Some imports not used depending on template conditions
// @ts-ignore
import { DUMMY_BASE_URL, assertParamExists, setApiKeyToObject, setBasicAuthToObject, setBearerAuthToObject, setOAuthToObject, setSearchParams, serializeDataIfNeeded, toPathString, createRequestFunction } from './common';
// @ts-ignore
import { BASE_PATH, COLLECTION_FORMATS, RequestArgs, BaseAPI, RequiredError } from './base';

/**
 * 
 * @export
 * @interface IAuthentication
 */
export interface IAuthentication {
    /**
     * 
     * @type {string}
     * @memberof IAuthentication
     */
    'refresh_token'?: string;
    /**
     * 
     * @type {string}
     * @memberof IAuthentication
     */
    'token'?: string;
    /**
     * 
     * @type {string}
     * @memberof IAuthentication
     */
    'session'?: string;
}
/**
 * 
 * @export
 * @interface ILogin
 */
export interface ILogin {
    /**
     * 
     * @type {string}
     * @memberof ILogin
     */
    'refresh_token'?: string;
    /**
     * 
     * @type {string}
     * @memberof ILogin
     */
    'username'?: string;
    /**
     * 
     * @type {string}
     * @memberof ILogin
     */
    'password'?: string;
    /**
     * 
     * @type {string}
     * @memberof ILogin
     */
    'session'?: string;
}

/**
 * LoginApi - axios parameter creator
 * @export
 */
export const LoginApiAxiosParamCreator = function (configuration?: Configuration) {
    return {
        /**
         * Authenticate
         * @param {ILogin} [iLogin] 
         * @param {*} [options] Override http request option.
         * @throws {RequiredError}
         */
        authenticate: async (iLogin?: ILogin, options: AxiosRequestConfig = {}): Promise<RequestArgs> => {
            const localVarPath = `/login`;
            // use dummy base URL string because the URL constructor only accepts absolute URLs.
            const localVarUrlObj = new URL(localVarPath, DUMMY_BASE_URL);
            let baseOptions;
            if (configuration) {
                baseOptions = configuration.baseOptions;
            }

            const localVarRequestOptions = { method: 'POST', ...baseOptions, ...options};
            const localVarHeaderParameter = {} as any;
            const localVarQueryParameter = {} as any;


    
            localVarHeaderParameter['Content-Type'] = 'application/json';

            setSearchParams(localVarUrlObj, localVarQueryParameter);
            let headersFromBaseOptions = baseOptions && baseOptions.headers ? baseOptions.headers : {};
            localVarRequestOptions.headers = {...localVarHeaderParameter, ...headersFromBaseOptions, ...options.headers};
            localVarRequestOptions.data = serializeDataIfNeeded(iLogin, localVarRequestOptions, configuration)

            return {
                url: toPathString(localVarUrlObj),
                options: localVarRequestOptions,
            };
        },
    }
};

/**
 * LoginApi - functional programming interface
 * @export
 */
export const LoginApiFp = function(configuration?: Configuration) {
    const localVarAxiosParamCreator = LoginApiAxiosParamCreator(configuration)
    return {
        /**
         * Authenticate
         * @param {ILogin} [iLogin] 
         * @param {*} [options] Override http request option.
         * @throws {RequiredError}
         */
        async authenticate(iLogin?: ILogin, options?: AxiosRequestConfig): Promise<(axios?: AxiosInstance, basePath?: string) => AxiosPromise<IAuthentication>> {
            const localVarAxiosArgs = await localVarAxiosParamCreator.authenticate(iLogin, options);
            return createRequestFunction(localVarAxiosArgs, globalAxios, BASE_PATH, configuration);
        },
    }
};

/**
 * LoginApi - factory interface
 * @export
 */
export const LoginApiFactory = function (configuration?: Configuration, basePath?: string, axios?: AxiosInstance) {
    const localVarFp = LoginApiFp(configuration)
    return {
        /**
         * Authenticate
         * @param {ILogin} [iLogin] 
         * @param {*} [options] Override http request option.
         * @throws {RequiredError}
         */
        authenticate(iLogin?: ILogin, options?: any): AxiosPromise<IAuthentication> {
            return localVarFp.authenticate(iLogin, options).then((request) => request(axios, basePath));
        },
    };
};

/**
 * LoginApi - object-oriented interface
 * @export
 * @class LoginApi
 * @extends {BaseAPI}
 */
export class LoginApi extends BaseAPI {
    /**
     * Authenticate
     * @param {ILogin} [iLogin] 
     * @param {*} [options] Override http request option.
     * @throws {RequiredError}
     * @memberof LoginApi
     */
    public authenticate(iLogin?: ILogin, options?: AxiosRequestConfig) {
        return LoginApiFp(this.configuration).authenticate(iLogin, options).then((request) => request(this.axios, this.basePath));
    }
}


