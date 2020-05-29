import React from 'react';
import classNames from 'classnames';
import ERC20BucketFactory from '../embarkArtifacts/contracts/ERC20BucketFactory';
import { RootState } from '../reducers';
import {
  shallowEqual,
  useSelector,
} from 'react-redux';
import { Web3Type } from "../actions/web3";
import "../styles/Layout.scss";

export default function(ownProps: any) {
  const props = useSelector((state: RootState) => {
    return {
      initialized: state.web3.networkID,
      networkID: state.web3.networkID,
      error: state.web3.error,
      account: state.web3.account,
      type: state.web3.type,
      sidebarOpen: state.layout.sidebarOpen,
    }
  }, shallowEqual);

  const sidebarClass = classNames({
    sidebar: true,
    open: props.sidebarOpen,
  });

  return <div className="main">
    {props.error && <div className={classNames({ paper: true, error: true })}>
      {props.error}
    </div>}

    {!props.error && !props.initialized && <div className={classNames({ paper: true })}>
      initializing...
    </div>}

    {!props.error && props.initialized && <div className="content">
      {ownProps.children}
    </div>}
  </div>;
}
