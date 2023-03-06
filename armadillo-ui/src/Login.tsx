import React, { useState } from 'react';
import { LoginApi,
  DefaultConfig, ApiEndpoint, AxiosInstance } from './client';

const Login: React.FC = () => {
  const [username, setUsername] = useState<string>()
  const [password, setPassword] = useState<string>()
  const [session, setSession] = useState<string|undefined>()

  const login = () => {
    const loginApi = new LoginApi(DefaultConfig, ApiEndpoint, AxiosInstance);
    loginApi.authenticate({
      session: session,
      username: username, 
      password: password})
      .then(({data})=> {
        if(data.session) {
          setSession(data.session)
          login()
        } else {
          console.log(data.token)
        }
      })
  }

  return (
    <div className="Login">
      <div className="box">
            <div className="field">
              <label className="label">Email</label>
              <div className="control has-icons-left">
                <input type="email" className="input" onChange={(event) => {
                  if (event) {
                    const { value } = event.target;
                    setUsername(value)
                  }
                }}/>
                <span className="icon is-small is-left">
                  <i className="fa fa-envelope"></i>
                </span>
              </div>
            </div>
            <div className="field">
              <label className="label">Password</label>
              <div className="control has-icons-left">
                <input type="password" placeholder="*******" className="input" onChange={(event) => {
                  if (event) {
                    const { value } = event.target;
                    setPassword(value)
                  }
                }}/>
                <span className="icon is-small is-left">
                  <i className="fa fa-lock"></i>
                </span>
              </div>
            </div>
            <div className="field">
              <button className="button is-success" onClick={login}>
                Login
              </button>
            </div>
          </div>
    </div>
  );
}

export default Login;
