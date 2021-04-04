import { LoadingOutlined } from '@ant-design/icons';
import { Spin } from 'antd';
import 'antd/dist/antd.css';
import routerConfig from 'configs/routerConfig';
import React, { Suspense, useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';
import { getUser } from 'redux/slices/user.slice';
import 'utils/scss/index.scss';
const NotFound = React.lazy(() => import('components/NotFound'));
const { mainRoutes, systemRoutes, renderRoutes } = routerConfig;

function App() {
  const { username, role } = useSelector((state) => state.user);
  const [isLoading, setIsLoading] = useState(true);
  const dispatch = useDispatch();
  const isAuth = username ? true : false;
  const routes = role === 'sys_admin' ? systemRoutes : mainRoutes;

  // get user
  useEffect(() => {
    setIsLoading(false);
    dispatch(getUser());
  }, []);

  return (
    <>
      {!isLoading && (
        <Router>
          <div className="App">
            <Suspense
              fallback={
                <Spin
                  className="trans-center"
                  size="large"
                  indicator={LoadingOutlined}
                  tip="Đang tải dữ liệu ..."
                />
              }>
              <Switch>
                {renderRoutes(routes, isAuth)}
                <Route>
                  <NotFound />
                </Route>
              </Switch>
            </Suspense>
          </div>
        </Router>
      )}
    </>
  );
}

export default App;
